// Attribute growth is lifetime XP. Level 1 starts at zero; each next level
// costs 25 + 10 * (level - 1). Derive levels without changing saved growth.
function progress(value) {
    var total = typeof value === 'number' && isFinite(value) ? Math.max(0, value) : 0;
    var completed = Math.max(0, Math.floor((Math.sqrt(400 + 20 * total) - 20) / 10));
    var start = 5 * completed * completed + 20 * completed;
    var cost = 25 + 10 * completed;
    return {level: completed + 1, xp: total - start, required: cost,
            fraction: Math.max(0, Math.min(1, (total - start) / cost)), total: total};
}
function display(value) { return (Math.floor(value * 10) / 10).toFixed(1).replace(/\.0$/, ''); }
