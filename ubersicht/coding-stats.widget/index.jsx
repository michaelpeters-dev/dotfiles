// Desktop widget: coding time (WakaTime) + competitive programming stats. Catppuccin Mocha.
// Data comes from ~/dotfiles/ubersicht/coding-stats.sh (refreshes every 5 minutes).
import { css } from "uebersicht";

export const command = "bash ~/dotfiles/ubersicht/coding-stats.sh";
export const refreshFrequency = 5 * 60 * 1000;

const C = {
  base: "#1e1e2e", surface0: "#313244", surface1: "#45475a", overlay0: "#6c7086",
  subtext: "#a6adc8", text: "#cdd6f4", mauve: "#cba6f7", green: "#a6e3a1",
  yellow: "#f9e2af", peach: "#fab387", blue: "#89b4fa",
};

// position: left side, below the bar (shows on any empty workspace)
export const className = css`
  left: 56px;
  top: 110px;
  width: 380px;
  padding: 22px 24px;
  border-radius: 16px;
  background: rgba(30, 30, 46, 0.88);
  border: 1px solid ${C.surface0};
  color: ${C.text};
  font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", Menlo, monospace;
  font-size: 12px;
  -webkit-font-smoothing: antialiased;
`;

const label = css`color: ${C.overlay0}; font-size: 11px; letter-spacing: 0.04em; margin-bottom: 8px;`;
const section = css`margin-top: 20px;`;

const fmt = (s) => `${Math.floor(s / 3600)}h ${String(Math.floor((s % 3600) / 60)).padStart(2, "0")}m`;
const dayName = (iso) => ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][new Date(iso + "T12:00:00").getDay()];

const Bar = ({ value, max, color, height = 6 }) => (
  <div style={{ background: C.surface0, borderRadius: 4, height, overflow: "hidden" }}>
    <div style={{ width: `${Math.min(100, (100 * value) / Math.max(1, max))}%`, height: "100%", background: color }} />
  </div>
);

const Stat = ({ value, name, color }) => (
  <div style={{ flex: 1, background: C.surface0, borderRadius: 10, padding: "10px 12px" }}>
    <div style={{ fontSize: 22, color }}>{value}</div>
    <div style={{ color: C.subtext, fontSize: 11, marginTop: 2 }}>{name}</div>
  </div>
);

const heatColor = (c) =>
  c === 0 ? C.surface0 : c === 1 ? "rgba(203,166,247,0.40)" : c <= 3 ? "rgba(203,166,247,0.70)" : C.mauve;

export const render = ({ output, error }) => {
  let d;
  try { d = JSON.parse(output); } catch (e) {
    return <div style={{ color: C.subtext }}>coding stats loading{error ? `: ${error}` : "..."}</div>;
  }
  const waka = d.waka || [];
  const today = waka.length ? waka[waka.length - 1].s : 0;
  const weekTotal = waka.reduce((a, x) => a + x.s, 0);
  const maxDay = Math.max(d.goal, ...waka.map((x) => x.s));
  const chartH = 70;

  // heatmap: columns are weeks, rows are days (oldest first)
  const cols = [];
  for (let i = 0; i < d.heat.length; i += 7) cols.push(d.heat.slice(i, i + 7));

  return (
    <div>
      <div className={label}>coding today</div>
      <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between" }}>
        <span style={{ fontSize: 30, color: today >= d.goal ? C.green : C.text }}>{fmt(today)}</span>
        <span style={{ color: C.subtext }}>goal {fmt(d.goal)}</span>
      </div>
      <div style={{ marginTop: 8 }}><Bar value={today} max={d.goal} color={C.green} height={8} /></div>

      <div className={section}>
        <div className={label}>last 7 days · {fmt(weekTotal)}</div>
        <div style={{ position: "relative", display: "flex", alignItems: "flex-end", gap: 10, height: chartH }}>
          <div style={{ position: "absolute", left: 0, right: 0, bottom: (chartH * d.goal) / maxDay, borderTop: `1px dashed ${C.overlay0}` }} />
          {waka.map((x, i) => (
            <div key={x.d} style={{ flex: 1, height: Math.max(2, (chartH * x.s) / maxDay), borderRadius: "4px 4px 0 0",
              background: i === waka.length - 1 ? C.mauve : x.s >= d.goal ? C.green : C.surface1 }} />
          ))}
        </div>
        <div style={{ display: "flex", gap: 10, marginTop: 4 }}>
          {waka.map((x) => <div key={x.d} style={{ flex: 1, textAlign: "center", color: C.overlay0, fontSize: 10 }}>{dayName(x.d)}</div>)}
        </div>
      </div>

      <div className={section}>
        <div className={label}>problems solved</div>
        <div style={{ display: "flex", gap: 8 }}>
          <Stat value={d.today} name="today" color={C.yellow} />
          <Stat value={d.week} name="7 days" color={C.mauve} />
          <Stat value={`${d.streak}d`} name="streak" color={C.peach} />
        </div>
      </div>

      <div className={section}>
        <div className={label}>last 13 weeks</div>
        <div style={{ display: "flex", gap: 4 }}>
          {cols.map((col, i) => (
            <div key={i} style={{ display: "flex", flexDirection: "column", gap: 4 }}>
              {col.map((x) => <div key={x.d} title={`${x.d}: ${x.c}`} style={{ width: 21, height: 10, borderRadius: 2, background: heatColor(x.c) }} />)}
            </div>
          ))}
        </div>
      </div>

      <div className={section}>
        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
          <span style={{ color: C.subtext }}>CSES</span>
          <span>{d.cses} / {d.csesTotal}</span>
        </div>
        <Bar value={d.cses} max={d.csesTotal} color={C.yellow} />
        <div style={{ display: "flex", justifyContent: "space-between", marginTop: 12 }}>
          <span style={{ color: C.subtext }}>LeetCode</span>
          <span>{d.leetcode} solved</span>
        </div>
      </div>
    </div>
  );
};
