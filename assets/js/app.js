(() => {
    const root = document.documentElement;
    const body = document.body;

    const storage = {
        get(key, fallback = null) {
            try { return localStorage.getItem(key) ?? fallback; } catch { return fallback; }
        },
        set(key, value) {
            try { localStorage.setItem(key, value); } catch {}
        }
    };

    const preferredTheme = () => {
        const stored = storage.get('benevolink.theme');
        if (stored === 'light' || stored === 'dark') return stored;
        return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    };

    const applyTheme = (theme) => {
        root.setAttribute('data-theme', theme);
        body.classList.toggle('is-dark', theme === 'dark');
        body.classList.toggle('is-light', theme !== 'dark');

        document.querySelectorAll('[data-theme-toggle]').forEach((button) => {
            button.setAttribute('aria-pressed', theme === 'dark' ? 'true' : 'false');
            button.textContent = theme === 'dark' ? '☀' : '◐';
            button.title = theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode';
        });

        const meta = document.querySelector('meta[name="theme-color"]');
        if (meta) meta.setAttribute('content', theme === 'dark' ? '#020617' : '#0f766e');
    };

    applyTheme(preferredTheme());

    document.addEventListener('click', (event) => {
        const themeButton = event.target.closest('[data-theme-toggle]');
        if (themeButton) {
            const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
            storage.set('benevolink.theme', next);
            applyTheme(next);
            toast(next === 'dark' ? 'Dark mode enabled.' : 'Light mode enabled.', 'success');
        }

        const mobileButton = event.target.closest('[data-mobile-toggle]');
        if (mobileButton) {
            body.classList.toggle('mobile-open');
        }

        const saveButton = event.target.closest('[data-save-toggle]');
        if (saveButton) {
            const id = saveButton.getAttribute('data-save-id');
            if (!id) return;
            const saved = new Set(getSaved());
            if (saved.has(id)) {
                saved.delete(id);
                toast('Removed from saved missions.', 'info');
            } else {
                saved.add(id);
                toast('Mission saved locally.', 'success');
            }
            setSaved([...saved]);
            refreshSavedUI();
        }

        const commandOpen = event.target.closest('[data-command-open]');
        if (commandOpen) openCommand();

        const commandClose = event.target.closest('[data-command-close]');
        if (commandClose) closeCommand();

        const popoverButton = event.target.closest('[data-popover-toggle]');
        if (popoverButton) {
            const key = popoverButton.getAttribute('data-popover-toggle');
            const panel = document.querySelector(`[data-popover="${key}"]`);
            if (panel) panel.classList.toggle('is-open');
        }

        if (!event.target.closest('[data-popover-toggle]') && !event.target.closest('[data-popover]')) {
            document.querySelectorAll('[data-popover].is-open').forEach((panel) => panel.classList.remove('is-open'));
        }
    });

    const overlay = document.querySelector('[data-command-overlay]');

    function openCommand() {
        if (!overlay) return;
        overlay.classList.add('is-open');
        overlay.setAttribute('aria-hidden', 'false');
        const input = overlay.querySelector('[data-command-search]');
        if (input) {
            input.value = '';
            filterCommand('');
            setTimeout(() => input.focus(), 30);
        }
    }

    function closeCommand() {
        if (!overlay) return;
        overlay.classList.remove('is-open');
        overlay.setAttribute('aria-hidden', 'true');
    }

    function filterCommand(value) {
        if (!overlay) return;
        const term = value.trim().toLowerCase();
        overlay.querySelectorAll('.command-list a').forEach((item) => {
            item.style.display = item.textContent.toLowerCase().includes(term) ? '' : 'none';
        });
    }

    if (overlay) {
        overlay.addEventListener('click', (event) => {
            if (event.target === overlay) closeCommand();
        });

        const input = overlay.querySelector('[data-command-search]');
        if (input) {
            input.addEventListener('input', () => filterCommand(input.value));
        }
    }

    document.addEventListener('keydown', (event) => {
        const isCommand = (event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k';
        if (isCommand) {
            event.preventDefault();
            openCommand();
        }
        if (event.key === 'Escape') {
            closeCommand();
            document.querySelectorAll('[data-popover].is-open').forEach((panel) => panel.classList.remove('is-open'));
        }
    });

    function getSaved() {
        try {
            return JSON.parse(localStorage.getItem('benevolink.savedMissions') || '[]');
        } catch {
            return [];
        }
    }

    function setSaved(items) {
        try {
            localStorage.setItem('benevolink.savedMissions', JSON.stringify(items));
        } catch {}
    }

    function refreshSavedUI() {
        const saved = new Set(getSaved());
        document.querySelectorAll('[data-save-toggle]').forEach((button) => {
            const id = button.getAttribute('data-save-id');
            const active = saved.has(id);
            button.classList.toggle('is-saved', active);
            button.textContent = active ? '★' : '☆';
            button.setAttribute('aria-pressed', active ? 'true' : 'false');
        });

        document.querySelectorAll('[data-saved-count]').forEach((target) => {
            target.textContent = `${saved.size} saved locally`;
        });
    }

    refreshSavedUI();

        const toast = window.BenevolinkNotifications.toast;

function escapeHtml(value) {
        return String(value)
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    const revealObserver = 'IntersectionObserver' in window
        ? new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('is-visible');
                    revealObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' })
        : null;

    document.querySelectorAll('.reveal').forEach((element, index) => {
        element.style.transitionDelay = `${Math.min(index * 32, 220)}ms`;
        if (revealObserver) {
            revealObserver.observe(element);
        } else {
            element.classList.add('is-visible');
        }
    });

    document.querySelectorAll('form').forEach((form) => {
        form.addEventListener('submit', () => {
            const button = form.querySelector('button[type="submit"]:not([data-no-loading])');
            if (!button) return;
            button.dataset.originalText = button.textContent;
            button.textContent = 'Working...';
            button.disabled = true;
        });
    });

    document.querySelectorAll('input[type="search"]').forEach((input) => {
        input.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                input.value = '';
            }
        });
    });

    function sendTrack(eventName, payload = {}) {
        const csrf = window.BENEVOLINK?.csrf;
        const baseUrl = window.BENEVOLINK?.baseUrl || window.location.pathname;
        if (!csrf || !baseUrl) return;

        const body = new URLSearchParams();
        body.set('csrf', csrf);
        body.set('action', 'track_event');
        body.set('event', eventName);
        if (payload.entityType) body.set('entity_type', payload.entityType);
        if (payload.entityId) body.set('entity_id', payload.entityId);
        if (payload.label) body.set('label', payload.label);
        if (payload.href) body.set('href', payload.href);
        if (payload.value) body.set('value', payload.value);

        fetch(baseUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body,
            keepalive: true
        }).catch(() => {});
    }

    function parseChartData(card) {
        try {
            const raw = card.getAttribute('data-chart-values') || '[]';
            const data = JSON.parse(raw);
            return Array.isArray(data) ? data.map((item) => ({
                label: String(item.label ?? 'Item'),
                value: Number(item.value ?? 0)
            })) : [];
        } catch {
            return [];
        }
    }

    function renderBarChart(card, data) {
        const canvas = card.querySelector('.chart-canvas');
        if (!canvas) return;
        const max = Math.max(...data.map((item) => item.value), 1);
        canvas.innerHTML = `<div class="bar-chart">${data.map((item, index) => {
            const width = Math.max(6, Math.round((item.value / max) * 100));
            return `
                <button type="button" class="bar-row" data-chart-point="${escapeHtml(item.label)}">
                    <span class="bar-label">${escapeHtml(item.label)}</span>
                    <span class="bar-track"><span style="width:${width}%"></span></span>
                    <strong>${escapeHtml(String(item.value))}</strong>
                </button>
            `;
        }).join('')}</div>`;
    }

    function renderDonutChart(card, data) {
        const canvas = card.querySelector('.chart-canvas');
        if (!canvas) return;
        const total = data.reduce((sum, item) => sum + Math.max(0, item.value), 0) || 1;
        let start = 0;
        const colors = ['#0f766e', '#38bdf8', '#f59e0b', '#7c3aed', '#22c55e', '#ef4444'];
        const stops = data.map((item, index) => {
            const amount = (Math.max(0, item.value) / total) * 100;
            const end = start + amount;
            const stop = `${colors[index % colors.length]} ${start}% ${end}%`;
            start = end;
            return stop;
        }).join(', ');

        canvas.innerHTML = `
            <div class="donut-wrap">
                <div class="donut" style="background: conic-gradient(${stops || '#e2e8f0 0 100%'})">
                    <span>${Math.round(total)}</span>
                </div>
                <div class="donut-legend">
                    ${data.map((item, index) => `
                        <button type="button" class="legend-row" data-chart-point="${escapeHtml(item.label)}">
                            <i style="background:${colors[index % colors.length]}"></i>
                            <span>${escapeHtml(item.label)}</span>
                            <strong>${escapeHtml(String(item.value))}</strong>
                        </button>
                    `).join('')}
                </div>
            </div>`;
    }

    function renderCharts() {
        document.querySelectorAll('[data-chart]').forEach((card) => {
            const data = parseChartData(card);
            const type = card.getAttribute('data-chart');
            if (type === 'donut') renderDonutChart(card, data);
            else renderBarChart(card, data);
        });
    }

    renderCharts();

    document.addEventListener('click', (event) => {
        const tracked = event.target.closest('[data-track-click], a, button');
        if (tracked && !tracked.matches('[data-command-close]')) {
            const label = tracked.getAttribute('data-track-click')
                || tracked.getAttribute('aria-label')
                || tracked.textContent?.trim()
                || tracked.href
                || 'interaction';
            sendTrack('ui_click', {
                label: label.slice(0, 120),
                href: tracked.href || '',
                entityType: tracked.getAttribute('data-entity-type') || '',
                entityId: tracked.getAttribute('data-entity-id') || ''
            });
        }

        const chartPoint = event.target.closest('[data-chart-point]');
        if (chartPoint) {
            toast(`Focused: ${chartPoint.getAttribute('data-chart-point')}`, 'info');
            sendTrack('chart_point_focus', { label: chartPoint.getAttribute('data-chart-point') || '' });
        }

        const scrollTarget = event.target.closest('[data-scroll-target]');
        if (scrollTarget) {
            const target = document.querySelector(scrollTarget.getAttribute('data-scroll-target'));
            if (target) target.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }

        const panelOpen = event.target.closest('[data-panel-open]');
        if (panelOpen) {
            const panel = document.querySelector(`[data-panel="${panelOpen.getAttribute('data-panel-open')}"]`);
            if (panel) {
                panel.scrollIntoView({ behavior: 'smooth', block: 'center' });
                panel.classList.add('is-highlighted');
                setTimeout(() => panel.classList.remove('is-highlighted'), 1600);
            }
        }

        const refresh = event.target.closest('[data-refresh-chart]');
        if (refresh) {
            renderCharts();
            toast('Dashboard refreshed.', 'success');
            sendTrack('dashboard_refresh', { label: 'chart refresh' });
        }

        const exportButton = event.target.closest('[data-export-table]');
        if (exportButton) {
            const target = document.getElementById(exportButton.getAttribute('data-export-table'));
            const text = target ? target.innerText : document.body.innerText;
            const blob = new Blob([text], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = 'benevolink-activity.txt';
            link.click();
            URL.revokeObjectURL(url);
            toast('Activity export created.', 'success');
            sendTrack('activity_exported', { label: 'activity export' });
        }
    });

    document.querySelectorAll('form').forEach((form) => {
        form.addEventListener('submit', () => {
            const action = form.querySelector('[name="action"]')?.value || 'unknown_form';
            sendTrack('form_submit_client', { label: action });
        });
    });

    document.querySelectorAll('.filter-form').forEach((form) => {
        form.addEventListener('submit', () => {
            const params = new URLSearchParams(new FormData(form));
            sendTrack('filter_search_submit', { label: params.toString().slice(0, 120) });
        });
    });

})();


/* Dashboard polish interactions */
(() => {
    const ensureNote = (card) => {
        let note = card.querySelector('.chart-focus-note');
        if (!note) {
            note = document.createElement('div');
            note.className = 'chart-focus-note';
            note.textContent = 'Click a segment or bar to inspect and record the interaction.';
            card.appendChild(note);
        }
        return note;
    };

    document.querySelectorAll('.chart-card').forEach((card) => {
        ensureNote(card);
    });

    document.addEventListener('click', (event) => {
        const point = event.target.closest('[data-chart-point]');
        if (point) {
            const card = point.closest('.chart-card');
            if (!card) return;
            card.querySelectorAll('[data-chart-point].is-selected').forEach((item) => item.classList.remove('is-selected'));
            point.classList.add('is-selected');
            ensureNote(card).textContent = `Focused data: ${point.getAttribute('data-chart-point')}`;
        }

        const refresh = event.target.closest('[data-refresh-chart]');
        if (refresh) {
            const card = refresh.closest('.chart-card, .dash-suite');
            if (card) {
                card.classList.add('is-refreshing');
                setTimeout(() => card.classList.remove('is-refreshing'), 700);
            }
        }
    });

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (entry.isIntersecting) entry.target.classList.add('is-visible');
        });
    }, { threshold: 0.12 });

    document.querySelectorAll('.dash-suite .chart-card, .dash-panel, .dash-mini-grid article').forEach((el) => observer.observe(el));
})();
