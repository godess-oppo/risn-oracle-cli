// AI-powered template recommendation
export function recommendTemplate(projectName: string): string {
  const patterns = detectProjectPatterns(projectName);
  return matchTemplate(patterns);
}

function detectProjectPatterns(name: string): string[] {
  // AI pattern detection logic
  if (/api|service|gateway/i.test(name)) return ['backend', 'cloud'];
  if (/web|ui|dashboard/i.test(name)) return ['frontend', 'responsive'];
  return ['default'];
}
