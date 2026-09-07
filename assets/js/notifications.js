(() => {
    /**
     * Toast/notification module.
     * Handles both:
     * - server-rendered flash toasts already present in the DOM
     * - client-side toasts triggered from app interactions
     */
    function escapeHtml(value) {
        return String(value)
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    function ensureStack() {
        let stack = document.querySelector('.client-toast-stack');
        if (!stack) {
            stack = document.createElement('div');
            stack.className = 'toast-stack client-toast-stack';
            document.body.appendChild(stack);
        }
        return stack;
    }

    function dismissToast(item, delay = 2600) {
        if (!item || item.dataset.dismissBound === '1') return;
        item.dataset.dismissBound = '1';

        window.setTimeout(() => {
            item.classList.add('is-leaving');
            item.style.opacity = '0';
            item.style.transform = 'translateY(-8px)';
        }, delay);

        window.setTimeout(() => {
            item.remove();
            const parent = item.parentElement;
            if (parent && parent.classList.contains('client-toast-stack') && !parent.children.length) {
                parent.remove();
            }
        }, delay + 500);
    }

    function bindExistingToasts() {
        document.querySelectorAll('.toast-stack .toast').forEach((item, index) => {
            dismissToast(item, 2200 + (index * 180));
        });
    }

    function toast(message, type = 'info') {
        const stack = ensureStack();
        const item = document.createElement('article');
        item.className = `toast toast-${type}`;
        item.innerHTML = `<span class="toast-icon"></span><p>${escapeHtml(message)}</p>`;
        stack.appendChild(item);
        requestAnimationFrame(() => item.classList.add('is-visible'));
        dismissToast(item, 2600);
    }

    document.addEventListener('DOMContentLoaded', bindExistingToasts);

    window.BenevolinkNotifications = {
        toast,
        bindExistingToasts
    };
})();
