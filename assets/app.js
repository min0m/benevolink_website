(() => {
    /**
     * Keeps the original asset path working.
     * Loads the split JavaScript files in order:
     * 1) notifications
     * 2) main app interactions
     */
    const base = 'assets/js/';
    const files = ['notifications.js', 'app.js'];

    const load = (src) => new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = base + src;
        script.defer = false;
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
    });

    files.reduce((chain, file) => chain.then(() => load(file)), Promise.resolve()).catch(() => {
        console.error('Failed to load split JS assets.');
    });
})();
