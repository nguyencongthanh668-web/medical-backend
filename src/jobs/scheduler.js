// Bộ lập lịch đơn giản không cần thư viện cron: chạy task ngay khi khởi động,
// sau đó mỗi ngày một lần vào đúng giờ hour:00 (giờ máy chủ).
function msUntilNext(hour, now = new Date()) {
    const next = new Date(now);
    next.setHours(hour, 0, 0, 0);
    if (next <= now) next.setDate(next.getDate() + 1);
    return next - now;
}

function scheduleDaily(hour, task, { runOnStart = true, logger = console } = {}) {
    let timer = null;
    let stopped = false;

    async function run() {
        try {
            const result = await task();
            logger.log(`[Bộ lập lịch] Quét hạn bảo dưỡng xong: ${JSON.stringify(result)}`);
        } catch (err) {
            logger.error('[Bộ lập lịch] Lỗi khi quét hạn bảo dưỡng:', err.message);
        }
    }

    function planNext() {
        if (stopped) return;
        timer = setTimeout(async () => {
            await run();
            planNext();
        }, msUntilNext(hour));
        timer.unref?.();
    }

    if (runOnStart) run();
    planNext();
    return () => {
        stopped = true;
        clearTimeout(timer);
    };
}

module.exports = { scheduleDaily, msUntilNext };
