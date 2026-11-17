import re
from typing import List, Dict, Optional, Tuple

class FuzzyNameMatcher:
    """
    Model 3 Component: Matches casually spoken names or nicknames from meeting
    transcripts (e.g. 'Rafey', 'Hifzan', 'Najeeb') to full registered employee
    profiles in Firestore (e.g. 'Abdul Rafey Mohammed', 'Mohammed Hifzan').
    """

    @staticmethod
    def _clean_token(text: str) -> str:
        """Lowercase and remove non-alphanumeric characters."""
        return re.sub(r'[^a-zA-Z0-9]', '', text.lower())

    @classmethod
    def _levenshtein_distance(cls, s1: str, s2: str) -> int:
        """Calculates edit distance between two strings."""
        if len(s1) < len(s2):
            return cls._levenshtein_distance(s2, s1)
        if len(s2) == 0:
            return len(s1)

        previous_row = range(len(s2) + 1)
        for i, c1 in enumerate(s1):
            current_row = [i + 1]
            for j, c2 in enumerate(s2):
                insertions = previous_row[j + 1] + 1
                deletions = current_row[j] + 1
                substitutions = previous_row[j] + (c1 != c2)
                current_row.append(min(insertions, deletions, substitutions))
            previous_row = current_row

        return previous_row[-1]

    @classmethod
    def similarity_score(cls, s1: str, s2: str) -> float:
        """Returns similarity ratio from 0.0 to 1.0."""
        s1_clean = cls._clean_token(s1)
        s2_clean = cls._clean_token(s2)
        if not s1_clean or not s2_clean:
            return 0.0
        if s1_clean == s2_clean:
            return 1.0

        max_len = max(len(s1_clean), len(s2_clean))
        distance = cls._levenshtein_distance(s1_clean, s2_clean)
        return max(0.0, 1.0 - (distance / max_len))

    @classmethod
    def match_name_to_participants(
        cls,
        spoken_name: Optional[str],
        participants: List[Dict[str, str]],
        threshold: float = 0.65
    ) -> Tuple[Optional[Dict[str, str]], float, bool]:
        """
        Matches a spoken name against meeting participants.
        
        Args:
            spoken_name: Extracted name string from Model 2 (e.g. 'Rafey').
            participants: List of employee dicts [{'uid': '...', 'name': 'Abdul Rafey Mohammed', 'phone': '...'}]
            threshold: Minimum confidence score to accept match (default: 65%).
            
        Returns:
            Tuple of:
            - Matched participant dict (or None)
            - Confidence score (0.0 to 1.0)
            - Needs clarification boolean flag
        """
        if not spoken_name or not spoken_name.strip():
            return None, 0.0, True

        target = cls._clean_token(spoken_name)
        best_match = None
        best_score = 0.0

        for p in participants:
            full_name = p.get('name', '')
            tokens = [cls._clean_token(t) for t in full_name.split() if t.strip()]

            # 1. Exact match with any token/part of the name (e.g. 'Rafey' in 'Abdul Rafey Mohammed')
            if target in tokens:
                return p, 1.0, False

            # 2. Check if spoken name starts with or is contained inside a token
            for t in tokens:
                if len(t) >= 3 and len(target) >= 3:
                    if target in t or t in target:
                        score = 0.90
                        if score > best_score:
                            best_score = score
                            best_match = p

            # 3. Fuzzy Levenshtein token match
            for t in tokens:
                score = cls.similarity_score(target, t)
                if score > best_score:
                    best_score = score
                    best_match = p

            # 4. Also compare against the full concatenated name
            full_score = cls.similarity_score(target, cls._clean_token(full_name))
            if full_score > best_score:
                best_score = full_score
                best_match = p

        if best_match and best_score >= threshold:
            needs_clarification = best_score < 0.80
            return best_match, round(best_score, 2), needs_clarification

        return None, round(best_score, 2), True
