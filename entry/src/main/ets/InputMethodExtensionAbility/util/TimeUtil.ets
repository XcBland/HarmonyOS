export function convertMsToHMS(ms: number): string {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor((seconds % 3600) / 60);
  const hours = Math.floor(seconds / 3600);
  const remainingSeconds = seconds % 60;

  // 补零处理，确保单个数字的小时、分钟、秒前面有前导零
  const formattedHours = String(hours).padStart(2, '0');
  const formattedMinutes = String(minutes).padStart(2, '0');
  const formattedSeconds = String(remainingSeconds).padStart(2, '0');

  return `${formattedHours}小时${formattedMinutes}分钟${formattedSeconds}秒`;
}
