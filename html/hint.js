
const container = document.getElementById('hint-container');
const hints = {};

const ICONS = {
    me:  'theater_comedy',
    'do': 'landscape',
    try: 'casino',
    med: 'local_hospital'
};

const LABELS = {
    me:  'ME',
    'do': 'DO',
    try: 'TRY',
    med: 'MED'
};

function createBubble(data) {
    const existing = hints[data.id];
    if (existing) {
        clearTimeout(existing.fadeTimeout);
        clearTimeout(existing.removeTimeout);
        existing.el.remove();
        delete hints[data.id];
    }

    const bubble = document.createElement('div');
    bubble.className = 'rp-hint-bubble';
    bubble.dataset.type = data.type;
    bubble.style.opacity = '0';

    const icon = ICONS[data.type] || 'chat';
    const label = LABELS[data.type] || data.type.toUpperCase();

    bubble.innerHTML = `
        <div class="rp-hint-card">
            <div class="rp-hint-header">
                <span class="rp-hint-icon">${icon}</span>
                <span class="rp-hint-label">${label}</span>
                <span class="rp-hint-name">${data.name}</span>
            </div>
            <div class="rp-hint-body">${data.text}${data.extra || ''}</div>
        </div>
        <div class="rp-hint-arrow"></div>
    `;

    container.appendChild(bubble);

    requestAnimationFrame(() => {
        bubble.style.opacity = '1';
    });

    const duration = data.duration || 8000;

    const fadeTimeout = setTimeout(() => {
        bubble.classList.add('fading');
    }, duration - 600);

    const removeTimeout = setTimeout(() => {
        bubble.remove();
        delete hints[data.id];
    }, duration);

    hints[data.id] = { el: bubble, fadeTimeout, removeTimeout };
}

function updatePositions(data) {
    for (const pos of data) {
        const hint = hints[pos.id];
        if (!hint) continue;

        const el = hint.el;
        el.style.left = (pos.x * 100) + '%';
        el.style.top = (pos.y * 100) + '%';

        const s = Math.max(0.55, Math.min(1.0, pos.scale));
        el.style.transform = `translate(-50%, -100%) scale(${s})`;
        el.style.opacity = Math.max(0.4, Math.min(1.0, pos.scale));
    }
}

function removeHint(id) {
    const hint = hints[id];
    if (!hint) return;
    clearTimeout(hint.fadeTimeout);
    clearTimeout(hint.removeTimeout);
    hint.el.classList.add('fading');
    setTimeout(() => {
        hint.el.remove();
        delete hints[id];
    }, 600);
}

window.addEventListener('message', (event) => {
    const msg = event.data;

    switch (msg.action) {
        case 'createHint':
            createBubble(msg.data);
            break;

        case 'updateHintPositions':
            updatePositions(msg.data);
            break;

        case 'removeHint':
            removeHint(msg.data.id);
            break;

        case 'removeAllHints':
            for (const id in hints) {
                removeHint(id);
            }
            break;
    }
});
