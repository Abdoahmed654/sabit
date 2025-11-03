/**
 * Calculate level from XP
 * Formula: level = floor(sqrt(xp / 100)) + 1
 */
export function calculateLevel(xp: number): number {
  return Math.floor(Math.sqrt(xp / 100)) + 1;
}

/**
 * Calculate XP required for next level
 */
export function xpForNextLevel(currentLevel: number): number {
  return (currentLevel * currentLevel) * 100;
}

/**
 * Calculate XP progress to next level
 */
export function xpProgress(currentXp: number): {
  currentLevel: number;
  xpForCurrent: number;
  xpForNext: number;
  progress: number;
} {
  const currentLevel = calculateLevel(currentXp);
  const xpForCurrent = (currentLevel - 1) * (currentLevel - 1) * 100;
  const xpForNext = currentLevel * currentLevel * 100;
  const progress = ((currentXp - xpForCurrent) / (xpForNext - xpForCurrent)) * 100;

  return {
    currentLevel,
    xpForCurrent,
    xpForNext,
    progress: Math.min(100, Math.max(0, progress)),
  };
}

