# SKILL Sprint-Session

## Vorlage — So strukturieren wir größere Projekte mit Claude Code

### Warum wir das so machen

Wenn ein größeres Projekt über viele Sprints, mehrere Sessions und unterschiedliche Terminals läuft, geht sonst fast immer der Gesamtzusammenhang verloren.

Dann passiert typischerweise Folgendes:
- Ein späterer Sprint sieht nur noch den letzten kleinen Task
- Das eigentliche Ziel verschwimmt
- Es wird an Seitenthemen gearbeitet, die lokal sinnvoll wirken, aber strategisch am Projekt vorbeigehen
- Bereits getroffene Architekturentscheidungen gehen verloren
- Der nächste Terminal weiß nicht mehr sauber, wo er ansetzen soll
- Das Kontextfenster läuft voll und die Qualität driftet ab, ohne dass es jemand merkt

Darum nutzen wir bei größeren Projekten ein festes System mit drei Modi.

---

### Die zwei Dokumente

**1. Master-Brief = Richtung (strategisch stabil)**

Ein strategisches Hauptdokument für das Gesamtprojekt.

Enthält:
- Vision / Nordstern
- Zielbild
- Architektur-Grundsätze
- Prioritäten + was explizit NICHT Priorität hat
- Regeln für die Arbeit an diesem Projekt
- Projekt-Aufteilung in Wellen → Sprints (mit Status-Tabelle)
- Gesamtfortschritt (X/N Sprints, aktuelle Welle)

Der Master-Brief ist die Leitplanke.
Er wird nicht nach jedem Sprint aufgebläht, sondern aktiv schlank gehalten:
- Status-Tabelle updaten (Sprint → ✅)
- Obsolete Detail-Notizen und überholte Annahmen entfernen
- Vision, Ziel, Architektur NIE entfernen — das bleibt immer
- Ziel: Jedes neue Terminal bekommt ein schlankes, präzises Dokument — kein aufgeblähtes Logbuch

**2. Sprint-Akte = Verlauf (operativ lebendig)**

Ein eigenes Dokument pro Sprint mit dem konkreten Auftrag und am Ende dem Ergebnis.

Enthält:
- Ziel des Sprints (welche Lücke wird geschlossen)
- Kontext aus dem Master-Brief (was muss dieses Terminal wissen)
- Detaillierte Tasks
- Akzeptanzkriterien
- Nach Abschluss: was gemacht wurde, was verifiziert wurde, was offen bleibt

Die Sprint-Akte ist das laufende Gedächtnis des Projekts.
Sie wird nach jedem Sprint sofort aktualisiert — nicht gesammelt später.

**Warum diese Trennung wichtig ist**

Beides darf nicht vermischt werden.
Sonst wird der Master-Brief irgendwann ein chaotisches Logbuch, oder die Sprint-Akte verliert die strategische Richtung.

- Master-Brief beantwortet: Warum? Was ist das Ziel? Welche Architektur? Welche Prioritäten?
- Sprint-Akte beantwortet: Was wurde konkret gemacht? Was ist grün? Was fehlt? Was kommt als Nächstes?

---

### Pfad-Konvention

Alle Projektdokumente leben unter einem festen Pfad:

```
docs/sprints/{projekt-name}/
├── master-brief.md           ← strategisch stabil
├── sprint-001.md             ← erster Sprint
├── sprint-002.md
├── sprint-003.md
├── sprint-003b.md            ← Fortsetzung (nach Kontextfenster-Abbruch)
└── ...
```

---

### Die drei Modi

#### Modus 1: :init — Projekt-Kickoff (Terminal 1)

Für den Start eines neuen Projekts. Aktivierung: `/sprint-session:init`

Was passiert:
1. Brainstorming — Vision, Ziele, Architektur klären (mit Visual Companion falls visuelle Fragen)
2. Projekt aufteilen in Wellen → Sprints
   - Kleine Projekte (1-3 Wellen): alles durchplanen
   - Komplexe Projekte (4+ Wellen): Welle 1-2 detailliert, Rest nur Grobziele
3. **Ausführungsmodus entscheiden** — Sequenziell oder Cluster? (siehe Abschnitt unten)
4. Master-Brief generieren
5. Sprint-Pläne generieren (bei Cluster: alle parallelen Sprints der ersten Runde)
6. Übergabe-Message mit den zwei Links ausgeben (bzw. Cluster automatisch starten)

Ergebnis: Du bekommst am Ende zwei Pfade, die du ins nächste Terminal kopierst — oder bei Cluster-Modus startet alles automatisch.

#### Modus 2: :work — Sprint abarbeiten (Terminal 2, 3, 4, ...)

Für jeden einzelnen Sprint. Aktivierung: Copy-Paste der zwei Links aus der Übergabe.

**Phase A — Einlesen (Pflicht, bevor irgendwas gebaut wird):**
1. Master-Brief lesen → Gesamtbild verstehen
2. Sprint-Plan lesen → konkreten Auftrag verstehen
3. Bestätigung: "Projekt verstanden, Sprint N starte ich jetzt — Ziel: ..."

**Phase B — Fragen klären (bevor losgecodet wird):**
- Architektur + Design (wo lebt was, wie fließen Daten, was sieht der User) → immer fragen
- Rein technische Entscheidungen (welche Library, welcher Loop-Typ) → selbst entscheiden
- Keine Seitenarbeit, keine spontanen Nebenprojekte, keine stillen Richtungswechsel

**Phase C — Arbeiten (Subagent-Driven):**
- Tasks mit Subagenten abarbeiten
- Nach jedem Task: Verifikation (gsd-verify)
- Fokus nur auf den Sprint, der gerade dran ist

**Phase D — Kontextfenster-Schutz (der kritischste Teil):**

Wenn das Kontextfenster sich dem Limit nähert:
- NICHT weitermachen und hoffen
- NICHT "noch schnell das letzte Feature"
- SOFORT sauber abbrechen:
  1. Aktuellen Task abschließen oder dokumentieren wo man steht
  2. Sprint-Akte aktualisieren (was geschafft, was offen)
  3. Master-Brief Status updaten
  4. Nächsten Sprint-Plan schreiben (sprint-NNNb für Fortsetzung)
  5. Übergabe-Message ausgeben

Faustregel: Immer 20% Kontext für die Übergabe-Dokumente reservieren. Lieber einen Sprint früher abbrechen als ins Chaos driften. Saubere Übergabe ist wichtiger als ein vollständiger Sprint.

**Phase E — Sprint abschließen:**
1. Sprint-Retro ausführen (Code Review + Security Audit + Metriken)
2. Drei Fragen an den User: Was lief gut? Was hat geblockt? Was ändern?
3. Sprint-Akte aktualisieren
4. Master-Brief verschlanken + updaten (Status-Tabelle, obsolete Infos raus)
5. Nächsten Sprint-Plan generieren
6. Übergabe-Message mit den zwei Links ausgeben

#### Modus 3: :review — Abschluss-Review (letztes Terminal)

Für den Abschluss einer Welle oder des Gesamtprojekts. Eigenes Terminal mit frischem Kontextfenster. Aktivierung: `/sprint-session:review`

Was passiert:
1. Master-Brief + alle Sprint-Akten lesen
2. Parallele Subagenten starten:
   - Code Review über ALLE Änderungen (ein Subagent pro System)
   - Security Audit über ALLE Änderungen
   - Inkonsistenzen zwischen Sprints finden
   - Tote Stellen, Lücken, halbfertige Übergänge
   - Vergessene Features (Sprint-Plan vs. tatsächlich umgesetzt)
3. Gefundene Fehler direkt fixen
4. E2E-Tests soweit möglich
5. Master-Brief finalisieren (Projekt-Status → ✅ wenn alles sauber)

Warum ein eigenes Terminal:
- Einzelne Sprints können lokal korrekt sein und trotzdem im Gesamtsystem Reibung erzeugen
- Über viele Sprints entstehen leicht tote Stellen, Lücken oder halbfertige Übergänge
- Ohne eigenen Abschluss-Review wird das Projekt zwar "gebaut", aber nicht wirklich "saubergezogen"

---

### Cluster-Modus — Parallele Sprints mit automatischer Koordination

Ab einer gewissen Projektgröße ist nicht mehr Code das Problem, sondern Koordination: Wer macht was, wann, in welcher Reihenfolge?

Der Cluster-Modus löst das. Statt Sprints nacheinander abzuarbeiten, laufen unabhängige Sprints parallel — und koordinieren sich selbst über ein Peer-Netzwerk ([claude-peers](https://github.com/louislva/claude-peers-mcp)).

**Wann Cluster statt sequenziell:**

| Kriterium | → Sequenziell | → Cluster |
|-----------|---------------|-----------|
| Sprints bauen aufeinander auf | ✅ | ❌ |
| Gleiche Dateien/gleiches System | ✅ | ❌ |
| Verschiedene Systeme (Backend + Frontend + API) | möglich | ✅ besser |
| Weniger als 3 Sprints | ✅ | Overhead lohnt nicht |
| Maximale Geschwindigkeit gewünscht | ❌ | ✅ |

**Wie es funktioniert:**

```
Terminal 1 (Orchestrator):
    /sprint-session:init → plant alle Sprints + Dependency-Graph
    Ruft spawn-cluster.sh auf → startet Worker automatisch in tmux

tmux Worker A:  Sprint 1 (Backend)   ──→ SPRINT_DONE:1
tmux Worker B:  Sprint 2 (Frontend)  ──→ SPRINT_DONE:2
                                              ↓
tmux Worker C:  Sprint 3 (Integration) ← freigeschaltet
                                              ↓
Terminal 1 (Orchestrator):  /sprint-session:review → E2E-Check → Projekt ✅
```

**Rollen:**
- **Orchestrator** — Plant, startet Worker, überwacht Fortschritt, gibt abhängige Sprints frei
- **Worker** — Arbeitet einen Sprint autonom ab, meldet Status, wartet bei Abhängigkeiten

**Für dich heißt das:** Du startest nur den Orchestrator. Der spawnt die Worker automatisch via tmux. Du kannst mit `tmux attach` reinschauen, aber musst nicht. Die Sessions koordinieren sich selbst.

**Voraussetzungen:**
- [claude-peers-mcp](https://github.com/louislva/claude-peers-mcp) installiert und in `.mcp.json` konfiguriert
- tmux installiert
- Alle Sessions auf demselben Server

---

### Der Flow — so sieht es in der Praxis aus

**Sequenziell (Standard):**

```
Terminal 1:  /sprint-session:init
             Brainstorming → Master-Brief + Sprint-001
                  ↓ copy-paste der zwei Links

Terminal 2:  Sprint 1 → Übergabe + Sprint-002
                  ↓ copy-paste

Terminal 3:  Sprint 2 → Übergabe + Sprint-003
                  ↓ copy-paste

Terminal 4:  Sprint 3 (Kontext knapp → sauberer Abbruch) + Sprint-003b
                  ↓ copy-paste

Terminal 5:  Sprint 3b → Übergabe + Sprint-004
                  ↓ copy-paste

Terminal 6:  [Welle 2 Nachplanung] → Sprint 4 → Übergabe + Sprint-005
                  ↓ ...

Terminal N:  /sprint-session:review → E2E-Check → Projekt ✅
```

**Cluster:**

```
Terminal 1:  /sprint-session:init → "Cluster oder sequenziell?" → Cluster
             spawn-cluster.sh startet 3 Worker in tmux
             Orchestrator überwacht → gibt Sprint 4 frei wenn 1+2 fertig
             /sprint-session:review → E2E-Check → Projekt ✅
```

Für dich heißt das: Du kopierst immer nur die zwei Links ins nächste Terminal (sequenziell) oder startest einmal den Orchestrator (Cluster). Den Rest macht Claude Code automatisch.

**Sonderfall — Neue Welle braucht Nachplanung:**
Wenn ein Sprint zur nächsten Welle gehört, die bei :init nur grob geplant wurde, erkennt Claude das selbst und plant kurz nach, bevor es losgeht.

**Sonderfall — Verbindungsabbruch (mobil unterwegs):**
Sag im neuen Terminal: "Session abgebrochen, wo stehen wir?" — Claude prüft dann git log, git status und die Sprint-Akten und sagt dir exakt, was fertig ist und was fehlt. Kein Chatverlauf nötig.

---

### Was nach jedem Sprint dokumentiert werden muss

Kein Sprint gilt als sauber abgeschlossen, wenn der Rückeintrag fehlt.

Die Sprint-Akte muss mindestens enthalten:

| Punkt | Was |
|-------|-----|
| Sprint-Name | Nummer + Titel (z.B. "Sprint 3 — Frontend-Grundgerüst") |
| Ziel | Welche Lücke sollte geschlossen werden |
| Umgesetzte Änderungen | Dateien, Endpoints, DB, UI, Sync/Events |
| Verifikation | Was wurde getestet, welche Flows sind nachweisbar grün |
| Neuer Stand | Was ist jetzt gelöst, was ist noch offen |
| Nächster Sprint | Konkret benennen + begründen |
| Risiken / offene Punkte | Legacy-Daten, Migration, Randfälle, technische Schulden |

Ablauf: erst umsetzen → dann verifizieren → dann Sprint-Akte aktualisieren → nur wenn nötig Master-Brief anpassen.

---

### Wann wir dieses System verwenden

**Ja, aktivieren wenn:**
- Projekt größer als ein einzelner Sprint
- Mehrere Sessions oder Terminals nötig
- Architekturentscheidungen enthalten
- Gefahr, im Kontextfenster verloren zu gehen
- Mehrstufiger Umbau, nicht nur ein Bugfix

**Nein, stattdessen gsd-quick (`/gsd-quick`) wenn:**
- Kleine Einmal-Fixes
- Ein-Datei-Anpassungen
- Aufgaben ohne Folge-Sprints
- Einfache Aufgaben die in 1-3 Tasks passen

---

### Unser Ziel mit diesem System

Wir wollen damit erreichen, dass auch nach 10, 20 oder 30 Sprints noch sofort klar ist:
- Was ist das eigentliche Projekt?
- Warum machen wir das?
- Was wurde schon geschafft?
- Was ist wirklich der nächste Schritt?
- Welche Richtung wäre falsch?

Kurz: Wir bauen damit ein externes Langzeitgedächtnis für große Bauprojekte.

---

### Merksatz

- Master-Brief = Richtung.
- Sprint-Akte = Verlauf.
- Kein Sprint ohne Rückeintrag.
- Kein neuer Terminal ohne beide Dokumente zu lesen.
- Saubere Übergabe > vollständiger Sprint.
