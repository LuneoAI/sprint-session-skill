---
name: sprint-session
description: "Sprint-Lifecycle-Management für Multi-Terminal-Projekte. 3 Modi: :init (Projekt-Kickoff mit Master-Brief + Sprint-Plan), :work (Sprint abarbeiten mit Kontextfenster-Schutz + sauberer Übergabe), :review (E2E-Abschluss-Review). Unterstützt Cluster-Modus via claude-peers für parallele Sprint-Koordination zwischen CC-Instanzen. Trigger: /sprint-session, 'neues Projekt planen', 'Sprint starten', Projekte > 1 Sprint."
---

# Sprint-Session — Sprint-Lifecycle für Multi-Terminal-Projekte

**Zweck:** Automatisches Management von Master-Brief + Sprint-Akten für größere Projekte. Verhindert Kontextverlust zwischen Terminals, sorgt für saubere Übergaben, schützt vor Kontextfenster-Überlauf.

**Merksatz:**
- Master-Brief = Richtung (strategisch stabil)
- Sprint-Akte = Verlauf (operativ lebendig)
- Kein Sprint ohne Rückeintrag
- Kein neuer Terminal ohne beide Dokumente zu lesen
- Saubere Übergabe > vollständiger Sprint
- Nach jedem Task: commit + push = Versicherung

## Wann aktivieren

- Neues Projekt > 1 Sprint / > 1 Terminal
- User gibt Master-Brief + Sprint-Plan Pfade an (→ :work Modus)
- User sagt "Abschluss-Review" oder alle Sprints sind durch (→ :review Modus)
- Projekt hat Architekturentscheidungen, mehrere Systeme, Folge-Sprints

## Wann NICHT aktivieren (stattdessen gsd-quick)

- Kleine Einmal-Fixes
- Ein-Datei-Anpassungen
- Aufgaben ohne Folge-Sprints

## Pfad-Konvention

```
docs/sprints/{projekt-name}/
├── master-brief.md           ← strategisch stabil
├── sprint-001.md             ← erster Sprint
├── sprint-002.md
├── sprint-003.md             ← aktueller Sprint
└── ...
```

---

## Sprint-Größe (Faustregel)

| Tasks pro Sprint | Bewertung |
|------------------|-----------|
| 1-2 Tasks | Zu klein — Übergabe-Overhead lohnt sich nicht, besser gsd-quick |
| 3-6 Tasks | Sweet Spot — genug Substanz, Kontextfenster bleibt sicher |
| 7-10 Tasks | Grenzwertig — nur wenn Tasks klein und klar sind |
| 10+ Tasks | Zu groß — Sprint aufteilen, Kontextfenster-Risiko zu hoch |

Wenn ein Sprint bei der Planung mehr als 6 substanzielle Tasks hat → in zwei Sprints aufteilen. Lieber zwei saubere Sprints als ein überfüllter, der im Kontextfenster-Limit abbricht.

---

## Ausführungsmodus — Empfehlung nach Planung

Nach der Planung bei :init analysiert Claude das Projekt und spricht eine **begründete Empfehlung** aus. Nicht einfach fragen — sondern basierend auf der Projektstruktur den passenden Modus empfehlen.

### Drei Optionen

| Modus | Wann passend | Typisches Projekt |
|-------|-------------|-------------------|
| **Quick Session** (`/gsd-quick`) | 1-3 Tasks, ein System, kein Folge-Sprint | Bugfix, kleine Anpassung, Refactoring |
| **Sprint-Plan** (sequenziell) | 2-6 Sprints, Abhängigkeiten zwischen Sprints, ein System | Feature-Entwicklung, schrittweiser Umbau |
| **Cluster-Plan** (parallel) | 3+ unabhängige Sprints, verschiedene Systeme | Multi-System-Projekt, großer Umbau über mehrere Bereiche |

### Empfehlungs-Logik (Claude macht das automatisch nach der Planung)

```
NACH der Planung (Wellen, Sprints, Tasks sind definiert):

1. Anzahl Sprints zählen
2. Abhängigkeiten zwischen Sprints analysieren
3. Betroffene Systeme/Verzeichnisse identifizieren
4. Empfehlung aussprechen:

WENN nur 1-3 Tasks und kein Folge-Sprint:
  → "Das ist überschaubar — ich würde das direkt als Quick Session machen."

WENN 2-6 Sprints und die meisten hängen voneinander ab:
  → "Das Projekt hat N Sprints die aufeinander aufbauen —
     ich empfehle einen Sprint-Plan, eins nach dem anderen."

WENN 3+ Sprints und mindestens 2 davon unabhängig voneinander:
  → "Das Projekt hat N Sprints über M verschiedene Systeme.
     Davon können X parallel laufen. Ich empfehle einen Cluster-Plan —
     das spart ungefähr Y Sprints an Wartezeit."

User entscheidet. Claude führt aus.
```

### Wie Claude die Empfehlung formuliert

Nach der Planung sagt Claude etwas wie:

> "So, das Projekt ist geplant: 6 Sprints über 3 Systeme, aufgeteilt in 2 Wellen.
>
> Jetzt zur Umsetzung — drei Optionen:
> - **Quick Session** — passt hier nicht, dafür ist es zu groß
> - **Sprint-Plan** — eins nach dem anderen, sicher und kontrolliert
> - **Cluster-Plan** — Sprint 1-3 können parallel laufen (verschiedene Systeme), Sprint 4-6 hängen davon ab
>
> **Meine Empfehlung: Cluster-Plan.** Sprint 1 (Backend), 2 (Frontend) und 3 (API) haben keine gemeinsamen Dateien und können gleichzeitig laufen. Das spart dir 2 Sprint-Zyklen. Sprint 4-6 folgen dann sequenziell.
>
> Was möchtest du?"

**Regeln für die Empfehlung:**
- Immer begründen WARUM dieser Modus passt
- Bei Cluster immer sagen WELCHE Sprints parallel können und welche nicht
- Bei Grenzfällen beide Optionen gleichwertig anbieten
- User-Entscheidung ist final — nicht nachverhandeln
- Quick Session nur empfehlen wenn das Projekt wirklich klein genug ist

### Sequenziell (Sprint-Plan)

Ein Terminal nach dem anderen. User öffnet neues Terminal, gibt zwei Links ein, nächster Sprint startet. Einfach, sicher, bewährt.

### Cluster-Modus (Cluster-Plan mit claude-peers)

Mehrere CC-Sessions arbeiten gleichzeitig an verschiedenen Sprints und koordinieren sich über das Peers-Netzwerk. **Voraussetzung:** `claude-peers` MCP-Server in `.mcp.json` konfiguriert.

**Rollen im Cluster:**

| Rolle | Aufgabe |
|-------|---------|
| **Orchestrator** | Plant, verteilt Sprints, überwacht Fortschritt, löst Abhängigkeiten |
| **Worker** | Führt einen Sprint aus, meldet Status, wartet auf Signale |

**Ablauf:**
1. Orchestrator-Session plant alle Sprints und erstellt Dependency-Graph
2. Orchestrator startet Worker-Sessions (User öffnet Terminals)
3. Jeder Worker setzt `set_summary` mit Sprint-Ziel
4. Worker arbeiten unabhängig, melden Fertigstellung via `send_message`
5. Orchestrator gibt abhängige Sprints frei wenn Vorbedingungen erfüllt
6. Am Ende: Orchestrator macht Integration + :review

**Dependency-Graph im Master-Brief:**

```markdown
## Cluster-Plan

### Dependency-Graph
Sprint 1 (Gravity-Backend) ──→ Sprint 3 (Solaris-Wiring)
Sprint 2 (Nova-Frontend)   ──→ Sprint 3 (Solaris-Wiring)
Sprint 4 (Matrix-Sync)     ──→ (unabhängig)

### Cluster-Zuweisung
| Sprint | System | Abhängig von | Cluster-Slot |
|--------|--------|-------------|--------------|
| Sprint 1 | Gravity | — | Slot A (parallel) |
| Sprint 2 | Nova | — | Slot B (parallel) |
| Sprint 3 | Solaris | Sprint 1 + 2 | Slot C (wartet) |
| Sprint 4 | Matrix | — | Slot A oder B (nach Freiwerden) |
```

**Peers-Nachrichten-Protokoll:**

| Signal | Von | An | Bedeutung |
|--------|-----|------|-----------|
| `SPRINT_STARTED:{N}` | Worker | Orchestrator | Sprint begonnen |
| `SPRINT_DONE:{N}` | Worker | Orchestrator | Sprint abgeschlossen, alle Tasks ✅ |
| `SPRINT_BLOCKED:{N}:{Grund}` | Worker | Orchestrator | Sprint hängt, braucht Hilfe |
| `DEPENDENCY_MET:{N}` | Orchestrator | Worker | Vorbedingung erfüllt, Sprint darf starten |
| `SYNC_REQUEST:{Details}` | Worker | Worker | Direkte Koordination zwischen Peers |

**Regeln für Cluster-Modus:**
- Jeder Worker hat **eigene Sprint-Akte** und **eigenen Guardian-Lock**
- Workers ändern **nie** Dateien die einem anderen Worker gehören
- Bei Konflikten: STOPPEN, Orchestrator benachrichtigen, nicht selbst lösen
- Orchestrator prüft via `list_peers` regelmäßig ob alle Worker noch leben
- Cluster-Modus erfordert Disziplin — im Zweifel lieber sequenziell

### Wann Cluster abbrechen und zu sequenziell wechseln

- Worker melden wiederholt Konflikte
- Mehr als 2 `SPRINT_BLOCKED` Signale in einer Cluster-Runde
- User sagt "zu komplex, eins nach dem anderen"
- Abhängigkeiten stellen sich als enger heraus als geplant

---

## Resilienz — Schutz vor Verbindungsabbruch + Stromausfall

### Auto-Commit + Push nach jedem Task (PFLICHT)

Nach jedem abgeschlossenen Task (nicht erst am Sprint-Ende):

```bash
git add -A && git commit -m "Sprint {N} Task {X}: {kurze Beschreibung}" && git push
```

**Warum:** Session kann jederzeit abbrechen — mobiles Internet, Stromausfall, Tunnel-Disconnect. Was gepusht ist, ist sicher. Was nur lokal liegt, ist verloren.

**Regeln:**
- Commit-Message immer mit Sprint-Nummer + Task-Nummer beginnen
- Push nach JEDEM Commit, nicht erst am Ende
- Auch Sprint-Dokumente (master-brief.md, sprint-NNN.md) committen + pushen
- Bei Verbindungsabbruch ist der letzte Push der Wiederherstellungspunkt

### Verbindungsabbruch-Protokoll

Wenn der User nach einem Abbruch ein neues Terminal öffnet:

**User sagt:** "Session abgebrochen, wo stehen wir?" oder gibt die zwei Links ein.

**Claude macht:**
1. `git log --oneline -20` → letzte Commits prüfen
2. `git status` → uncommittete Änderungen finden
3. Sprint-Akte lesen → was war geplant vs. was ist committed
4. Bericht an User: "Sprint N war bei Task X. Tasks 1-3 sind committed + gepusht. Task 4 war halb fertig — ich sehe uncommittete Änderungen in [Dateien]. Soll ich Task 4 fertigmachen oder zurücksetzen?"
5. Falls uncommittete Änderungen sauber aussehen → committen + pushen
6. Falls uncommittete Änderungen inkonsistent → `git stash` und sauber neu anfangen

**Wichtig:** Kein Chatverlauf nötig. Git-History + Sprint-Dokumente sind die Wahrheit.

### Wenn User mobil unterwegs ist

Wenn der User sagt "Ich bin mobil" oder "Bin unterwegs":
- **Noch häufiger committen** — nach jeder substanziellen Dateiänderung, nicht nur nach Tasks
- **Kürzere Sprints planen** — 3-4 Tasks statt 5-6
- **Übergabe-Dokumente früher schreiben** — ab 50% des Sprints bereits vorbereiten
- **Keine langen Build-Prozesse** starten die bei Abbruch Inkonsistenzen hinterlassen

---

## Modus 1: :init — Projekt-Kickoff

**Trigger:** Neues größeres Projekt starten.

### Ablauf

1. **Brainstorming aufrufen** → Vision, Ziele, Architektur klären
   - Visual Companion nutzen falls visuelle Fragen: `https://brainstorm.luneo.cloud/`
2. **Projekt aufteilen** in Wellen → Etappen → Sprints
   - Kleine Projekte (1-3 Wellen): ALLES durchplanen
   - Komplexe Projekte (4+ Wellen): Welle 1-2 detailliert, Rest grob (Ziele, nicht Tasks)
3. **Ausführungsmodus empfehlen** → Nach der Planung analysieren und begründet empfehlen:
   - Sprints auf Abhängigkeiten analysieren: Welche können parallel laufen?
   - Betroffene Systeme/Verzeichnisse identifizieren
   - Begründete Empfehlung aussprechen: Quick Session, Sprint-Plan oder Cluster-Plan
   - User entscheidet — Claude führt den gewählten Modus aus
   - Bei Cluster: Dependency-Graph erstellen und in Master-Brief aufnehmen
4. **Master-Brief generieren** (`docs/sprints/{name}/master-brief.md`)
   - Bei Cluster-Modus: `## Cluster-Plan` Abschnitt mit Dependency-Graph und Slot-Zuweisung
5. **Sprint-Pläne generieren**
   - Sequenziell: nur ersten Sprint (`sprint-001.md`)
   - Cluster: alle parallelen Sprints der ersten Runde (`sprint-001.md`, `sprint-002.md`, ...)
6. **Übergabe-Message ausgeben**
   - Sequenziell: wie bisher (zwei Links)
   - Cluster: Orchestrator-Anweisungen (welche Terminals öffnen, welcher Sprint wohin)

### Master-Brief Template

```markdown
# Master-Brief: {Projektname}

> Erstellt: {Datum} | Letztes Update: {Datum}

## Vision / Nordstern
{Was wollen wir erreichen und warum}

## Zielbild
{Wie sieht das Endergebnis aus}

## Architektur-Grundsätze
{Technische Leitplanken}

## Prioritäten
1. {Höchste Priorität}
2. ...

## Nicht Priorität (bewusst ausgeklammert)
- {Was wir bewusst NICHT machen}

## Regeln für die Arbeit
- Subagent-driven Development (immer)
- Kein Sprint ohne Rückeintrag
- Kein neuer Terminal ohne Master-Brief + Sprint-Akte zu lesen
- Bei Kontextfenster-Limit: sauber abbrechen, nicht weiterwursteln
- Bei Architektur/Design-Unklarheiten: STOPPEN und fragen

## Quality-Baseline
{3-5 Zeilen die definieren was "sauberer Code" in diesem Projekt heißt. Jeder Sprint-Retro prüft dagegen.}
- Stil: {z.B. camelCase für JS, snake_case für Python}
- Architektur: {z.B. "Controller → Service → Repository, keine Shortcuts"}
- Tests: {z.B. "Jeder Endpoint hat mindestens einen Happy-Path-Test"}
- UI: {z.B. "Echte Umlaute, keine Inline-Styles, responsive ab 768px"}

## Entscheidungen
| # | Entscheidung | Warum | Sprint |
|---|-------------|-------|--------|
| — | Wird im Projektverlauf gefüllt | — | — |

## Projekt-Aufteilung

### Welle 1: {Name}
| Sprint | Ziel | Status | Datum |
|--------|------|--------|-------|
| Sprint 1 | {Ziel} | ⬜ offen | — |
| Sprint 2 | {Ziel} | ⬜ offen | — |

### Welle 2: {Name}
| Sprint | Ziel | Status | Datum |
|--------|------|--------|-------|
| Sprint 3 | {Ziel} | ⬜ offen | — |

**Status-Legende:** ⬜ offen | 🔄 in Arbeit | ✅ erledigt | ⏭️ übersprungen

## Gesamtfortschritt
- **Sprints gesamt:** N
- **Erledigt:** 0/N (0%)
- **Aktuelle Welle:** 1
- **Nächster Sprint:** Sprint 1
```

### Sprint-Plan Template

```markdown
# Sprint {NNN}: {Titel}

> Projekt: {Projektname} | Datum: {Datum}
> Master-Brief: docs/sprints/{name}/master-brief.md

## Ziel dieses Sprints
{Welche Lücke wird geschlossen}

## Kontext (aus Master-Brief)
{Relevanter Auszug — was muss dieses Terminal wissen}

## Tasks
{Detaillierte Tasks im GSD-Plan-Format mit <task>-XML}

## Akzeptanzkriterien
- [ ] {Was muss am Ende grün sein}

## Nach diesem Sprint
- Sprint-Akte aktualisieren
- Master-Brief Status-Tabelle updaten
- Nächsten Sprint-Plan vorbereiten
```

---

## Modus 2: :work — Sprint-Arbeit

**Trigger:** User gibt Master-Brief + Sprint-Plan Pfade an. Oder dieses Terminal soll den nächsten Sprint aus der Übergabe des vorherigen Terminals abarbeiten.

### Phase A — Einlesen (PFLICHT)

1. **Master-Brief lesen** → Gesamtbild verstehen (Vision, Architektur, aktueller Stand)
2. **Sprint-Plan lesen** → konkreten Auftrag verstehen
3. **Bestätigung an User:** "Projekt verstanden, Sprint {N} starte ich jetzt — Ziel: {Ziel}"

### Phase B — Fragen klären (BEVOR losgecodet wird)

4. Sprint-Plan durchgehen: Ist alles klar genug um loszulegen?
5. Falls Unklarheiten bei **Architektur, Design oder Richtung**: **STOPPEN und fragen**
   - Beispiel: "Bevor ich Sprint 3 starte — ich habe 2 Fragen:"
   - "1. Soll der neue Endpoint unter /api/v2 oder /api/v1 laufen?"
   - "2. Die Datenbank-Migration — bestehend erweitern oder neu?"
6. **Rein technische Entscheidungen** (welche Library, welcher Loop-Typ) → selbst entscheiden
7. **Architektur + Design** (wo lebt was, wie fließen Daten, was sieht der User) → **immer fragen**
8. Falls visuelle Fragen → Visual Companion: `https://brainstorm.luneo.cloud/`

### Phase B.1 — Peers-Setup (nur im Cluster-Modus)

Falls der Master-Brief einen Cluster-Plan enthält:

6. **Peers-Netzwerk prüfen:** `list_peers` (scope: machine) — wer ist noch da?
7. **Eigene Rolle erkennen:**
   - Orchestrator: Überwacht, gibt Sprints frei, macht am Ende Integration
   - Worker: Führt zugewiesenen Sprint aus, meldet Status
8. **Summary setzen:** `set_summary` mit "Sprint {N}: {Ziel} [{System}]"
9. **Als Worker:** Auf `DEPENDENCY_MET` warten falls Sprint Abhängigkeiten hat
10. **Als Orchestrator:** Peers überwachen, bei `SPRINT_DONE` nächste Abhängigkeiten freigeben

### Phase C — Arbeiten (Subagent-Driven)

9. Tasks aus Sprint-Plan mit `subagent-driven-development` abarbeiten
10. Nach jedem Task: `gsd-verify` auf diesen Task
11. **Nach jedem verifizierten Task: commit + push** (Sprint-N Task-X: Beschreibung)
12. Auch WÄHREND der Arbeit darf gestoppt und gefragt werden
13. **Kontextfenster-Awareness:** Fortlaufend eigenen Kontextverbrauch einschätzen
14. **Im Cluster-Modus:** Summary nach jedem Task aktualisieren (`set_summary` mit Fortschritt)

### Phase C.1 — Multi-Terminal-Awareness

Wenn mehrere Terminals gleichzeitig aktiv sind (häufiger Fall: 4-5 Terminals):

14. **Zu Beginn prüfen:** `git log --oneline -5` — arbeitet ein anderes Terminal gerade am selben Projekt?
15. **Guardian-Status prüfen:** Gibt es aktive Locks auf das Zielsystem?
16. **Abgrenzung klären:** Falls ein anderes Terminal aktiv ist:
    - Welches System/Verzeichnis bearbeitet es?
    - Gibt es Überschneidungen mit meinem Sprint?
    - Falls ja: User informieren und Reihenfolge klären
    - Falls nein: parallel weiterarbeiten, aber eigenen Scope klar eingrenzen
17. **Vor jedem Push:** `git pull --rebase` um Konflikte mit anderen Terminals zu vermeiden
18. **Bei Merge-Konflikten:** STOPPEN, User informieren, nicht blind resolven

### Phase D — Kontextfenster-Schutz (KRITISCH)

```
WENN Kontextfenster sich dem Limit nähert:
  → NICHT weitermachen und hoffen
  → NICHT "noch schnell das letzte Feature"
  → SOFORT sauber abbrechen:
    1. Aktuellen Task abschließen oder markieren wo man steht
    2. Sprint-Akte aktualisieren (was geschafft, was offen)
    3. Master-Brief Status updaten
    4. Nächsten Sprint-Plan schreiben (sprint-NNNb für Fortsetzung)
    5. Übergabe-Message ausgeben
```

**Regeln:**
- Lieber einen Sprint früher abbrechen als ins Chaos driften
- Nie "noch schnell" etwas machen wenn das Fenster knapp wird
- Immer 20% Kontext reservieren für Übergabe-Dokumente
- Faustregel: Nach 3-4 komplexen Tasks aktiv prüfen ob Übergabe sinnvoll ist
- Bei Zeichen von Stress (Wiederholungen, Vergessen, Inkonsistenzen): SOFORT stoppen
- Saubere Übergabe > vollständiger Sprint

### Phase E — Sprint abschließen

13. **Im Cluster-Modus (Worker):** `send_message` an Orchestrator: `SPRINT_DONE:{N}`
    - Summary aktualisieren: `set_summary` mit "Sprint {N} ✅ abgeschlossen"
    - Auf nächste Anweisung vom Orchestrator warten (neuer Sprint oder "fertig")
14. **Im Cluster-Modus (Orchestrator):** Bei `SPRINT_DONE` von Worker:
    - Dependency-Graph prüfen: Sind jetzt neue Sprints freigegeben?
    - Falls ja: `send_message` mit `DEPENDENCY_MET:{N}` an wartende Worker
    - Falls alle Sprints durch: Integration + :review starten
15. `sprint-retro` ausführen (Code Review + Security + Metriken + 3 User-Fragen)
    - **Quality-Baseline-Check:** Code gegen die Quality-Baseline im Master-Brief prüfen
    - Drift erkennen: Hat dieser Sprint den Stil, die Architektur oder die Testabdeckung verschlechtert?
    - Falls ja: als Finding dokumentieren und im nächsten Sprint korrigieren
14. Sprint-Akte aktualisieren
15. **Entscheidungs-Log pflegen:** Wurden in diesem Sprint Architektur- oder Design-Entscheidungen getroffen?
    - Falls ja: Eine Zeile pro Entscheidung in die `## Entscheidungen`-Tabelle im Master-Brief eintragen
    - Format: Was wurde entschieden | Warum | In welchem Sprint
    - Nur nicht-triviale Entscheidungen (Architektur, Technologiewahl, bewusste Trade-offs)
    - Rein technische Implementierungsdetails gehören NICHT hierhin
16. **Master-Brief verschlanken + updaten:**
    - Status-Tabelle updaten (Sprint → ✅, Gesamtfortschritt aktualisieren)
    - Obsolete Informationen entfernen (erledigte Detail-Notizen, überholte Annahmen)
    - Vision, Ziel, Architektur **NIE entfernen** — das bleibt immer
    - Entscheidungs-Log und Quality-Baseline **NIE entfernen** — das wächst mit dem Projekt
    - Nur das Wichtigste behalten: was definiert wurde, was gemacht werden muss, grob wie
    - Ziel: Nächstes Terminal bekommt ein schlankes, präzises Dokument — nicht ein aufgeblähtes Logbuch
17. Nächsten Sprint-Plan generieren
18. **Übergabe-Message ausgeben** (siehe Format unten)

### Übergabe-Format (PFLICHT am Ende jeder Session)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SPRINT {N} ABGESCHLOSSEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Was ich erledigt habe

| # | Task | Status |
|---|------|--------|
| 1 | {Task-Name} | ✅ erledigt |
| 2 | {Task-Name} | ✅ erledigt |
| 3 | {Task-Name} | ⚠️ teilweise (Grund) |

## Was jetzt funktioniert
- {Feature/Endpoint/UI-Element das jetzt live ist}
- {Was vorher nicht ging und jetzt geht}

## Was der nächste Sprint macht
- {Sprint N+1 Ziel}
- {Konkrete Tasks grob}
- {Was danach noch kommt}

## Deine zwei Links

Terminal fertig. Öffne ein neues Terminal und gib ein:

> Hier ist der Master-Brief: `docs/sprints/{name}/master-brief.md`
> Und hier der Sprint-Plan: `docs/sprints/{name}/sprint-{N+1}.md`
> Lies beides, dann arbeite Sprint {N+1} ab.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Modus 3: :review — Review (Zwischen-Review + Abschluss-Review)

**Trigger:** Ende einer Welle ODER Abschluss des Gesamtprojekts. Eigener Terminal mit frischem Kontextfenster.

### Zwei Review-Stufen

| Stufe | Wann | Umfang | Dauer |
|-------|------|--------|-------|
| **Wellen-Review** (leichtgewichtig) | Nach jeder abgeschlossenen Welle | Konsistenz + Quality-Baseline | 1 Terminal, schnell |
| **Abschluss-Review** (vollständig) | Nach dem letzten Sprint | E2E über alles | 1 Terminal, gründlich |

### Wellen-Review (nach jeder Welle)

1. **Master-Brief lesen** → welche Sprints gehören zu dieser Welle
2. **Sprint-Akten dieser Welle lesen** → was wurde gemacht
3. **Konsistenz-Check** (ein Subagent):
   - Passen die Sprints dieser Welle zusammen?
   - Quality-Baseline eingehalten? (Stil, Architektur, Tests)
   - Entscheidungen aus verschiedenen Sprints widersprüchlich?
   - Gibt es halbfertige Übergänge zwischen Sprints?
4. **Gefundene Probleme sofort fixen** — kleine Korrekturen direkt, größere als Task in nächste Welle
5. **Master-Brief updaten:** Welle → ✅, Findings dokumentieren
6. **Nächste Welle detailliert planen** falls nur Grobziele vorhanden

### Abschluss-Review (nach dem letzten Sprint)

1. **Master-Brief lesen** → alle Wellen/Sprints und deren Status
2. **Alle Sprint-Akten lesen** → was wurde in jedem Sprint gemacht
3. **E2E-Review** (parallele Subagenten):
   - Code Review auf GESAMTE Änderungen (ein Subagent pro System)
   - Security Audit auf GESAMTE Änderungen
   - Quality-Baseline-Drift über das ganze Projekt (Sprint 1 vs. letzter Sprint)
   - Inkonsistenzen zwischen Sprints finden
   - Tote Stellen, Lücken, halbfertige Übergänge
   - Vergessene Features (Sprint-Plan vs. tatsächlich umgesetzt)
   - Entscheidungs-Log prüfen: Wurden alle Entscheidungen eingehalten oder still unterwandert?
4. **Gefundene Fehler direkt fixen** (Subagent-Driven)
5. **E2E-Tests** soweit möglich
6. **Review-Report generieren**
7. **Master-Brief finalisieren** (Projekt-Status → ✅ wenn alles sauber)

---

## Planungs-Intelligenz

**Kernprinzip:** Am Anfang ausgiebig planen — danach schnell umsetzen.

**Keine Neuplanung wenn:**
- Sprint-Plan ist klar und detailliert → sofort loslegen
- Nur weil ein neues Terminal gestartet wurde → Master-Brief + Sprint-Plan lesen reicht
- Kleine Abweichungen → im Sprint-Plan dokumentieren, nicht neu planen

**Neuplanung nötig wenn (Skill erkennt das selbst):**
- Nächste Welle hat nur Grobziele, keine konkreten Tasks
  → "Welle 3 ist noch nicht detailliert — bevor ich Sprint 5 starte, plane ich kurz durch"
- Architektur-Entscheidung aus vorherigem Sprint verändert den Plan
- Sprint-Plan referenziert Tasks die nicht klar genug sind
- User sagt explizit: "Plan nochmal anpassen"

### Scope-Creep-Erkennung (automatisch)

**Trigger:** Der Skill prüft bei jedem Sprint-Abschluss den Gesamtfortschritt im Master-Brief.

```
WENN tatsächliche Sprint-Anzahl > 150% der ursprünglich geplanten Anzahl:
  → AUTOMATISCH Scope-Check auslösen
```

**Beispiel:** Ursprünglich 8 Sprints geplant, wir sind jetzt bei Sprint 13 und es ist kein Ende in Sicht.

**Claude sagt dann:**

> ⚠️ **Scope-Check:** Das Projekt ist deutlich größer geworden als geplant
> (ursprünglich 8 Sprints, aktuell 13, geschätzt noch 5 offen).
>
> Drei Optionen:
> **A) Scope reduzieren** — Was können wir weglassen? Was ist nice-to-have?
> **B) Bewusst weitermachen** — Der zusätzliche Umfang ist gerechtfertigt, weiter wie geplant.
> **C) Projekt aufteilen** — Phase 1 hier abschließen, Rest als eigenständiges Folgeprojekt.
>
> Welche Option?

**Regeln:**
- Scope-Check ist eine Frage, kein Blocker — der User entscheidet
- Nach Entscheidung: Master-Brief updaten (neue Sprint-Anzahl oder reduzierter Scope)
- Bei Option C: Aktuelles Projekt sauber mit :review abschließen, neuen :init für Phase 2
- Scope-Check maximal einmal pro Welle, nicht bei jedem Sprint wiederholen

---

## Rollback-Strategie — Wenn ein Sprint Code kaputt macht

### Erkennung

Nach `gsd-verify` oder `sprint-retro` stellt sich heraus: Der Sprint hat etwas beschädigt.

### Sofort-Maßnahmen

1. **Schadensanalyse:** `git diff HEAD~{N}` — was wurde in diesem Sprint alles geändert?
2. **Lokalisieren:** Welche Datei(en) sind das Problem? Alles oder nur ein Teil?
3. **Entscheidung:**

| Situation | Aktion |
|-----------|--------|
| Ein Task hat einen Bug eingeführt | Bug fixen, nicht den ganzen Sprint zurückrollen |
| Mehrere Tasks sind kaputt verwoben | `git stash` für uncommittete Änderungen, dann Task-für-Task prüfen |
| Sprint hat grundlegend falsche Richtung genommen | `git revert` der Sprint-Commits (erzeugt Gegen-Commits, Geschichte bleibt) |
| Alles ist kaputt, nichts zu retten | Guardian-Snapshot als Fallback: `bash /root/guardian/scripts/guardian-snapshot.sh` |

### Regeln

- **Nie `git reset --hard` ohne explizite User-Bestätigung** — das zerstört History
- **Immer `git revert` statt `git reset`** — Geschichte bleibt erhalten
- **Guardian-Snapshot ist der letzte Fallback**, nicht die erste Option
- Nach Rollback: Sprint-Akte aktualisieren mit "Sprint N zurückgerollt, Grund: ..."
- Neuen Sprint-Plan schreiben der das Problem berücksichtigt

---

## Parallele Sprints — Cluster-Koordination mit claude-peers

### Voraussetzungen

- `claude-peers` MCP-Server in `.mcp.json` konfiguriert
- Broker läuft auf localhost:7899 (wird automatisch gestartet)
- Alle Sessions auf demselben Server (116.203.236.82)
- Guardian-Locks für jedes System separat angefordert

### Wann Cluster-Modus erlaubt

- Sprints betreffen **verschiedene Systeme/Verzeichnisse** (z.B. Backend + Frontend)
- Sprints ändern **keine gemeinsamen Dateien**
- Dependency-Graph ist klar — welche Sprints können parallel, welche müssen warten
- Mindestens 3 Sprints die von Parallelisierung profitieren

### Wann sequenziell bleiben

- Sprints die dieselben Dateien oder dasselbe System betreffen
- Sprints die eng aufeinander aufbauen (Sprint 3 braucht Ergebnis von Sprint 2)
- Weniger als 3 Sprints gesamt (Cluster-Overhead lohnt nicht)
- Im Zweifel → sequenziell. Parallelität ist Optimierung, nicht Standard.

### Cluster-Ablauf (Zusammenfassung)

1. **:init** plant alle Sprints + erstellt Dependency-Graph im Master-Brief
2. **User öffnet N Terminals** — jedes mit eigenem Sprint-Plan
3. **Jedes Terminal** registriert sich automatisch im Peers-Netzwerk
4. **Orchestrator-Terminal** überwacht via `list_peers` und koordiniert via `send_message`
5. **Worker-Terminals** melden Fortschritt und warten auf Freigaben
6. **Nach Abschluss aller Worker:** Orchestrator macht Integration + :review

### Cluster-Übergabe-Format

Statt der normalen "zwei Links" Übergabe gibt der Orchestrator bei :init aus:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CLUSTER-SPRINT VORBEREITET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Modus: Cluster ({N} parallele Sprints)

| Terminal | Sprint | System | Sprint-Plan |
|----------|--------|--------|-------------|
| A | Sprint 1 | {System} | docs/sprints/{name}/sprint-001.md |
| B | Sprint 2 | {System} | docs/sprints/{name}/sprint-002.md |
| C | (wartet) | {System} | docs/sprints/{name}/sprint-003.md |

## Abhängigkeiten
Sprint 3 wartet auf Sprint 1 + 2

## So startest du die Worker

Öffne Terminal A:
> Master-Brief: docs/sprints/{name}/master-brief.md
> Sprint-Plan: docs/sprints/{name}/sprint-001.md
> Modus: Cluster-Worker

Öffne Terminal B:
> Master-Brief: docs/sprints/{name}/master-brief.md
> Sprint-Plan: docs/sprints/{name}/sprint-002.md
> Modus: Cluster-Worker

Dieses Terminal bleibt Orchestrator.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
