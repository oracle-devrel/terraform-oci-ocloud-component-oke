### Summary
|              |                                    |
| ------------ | ---------------------------------- |
| **Theme**    | Seven Steps to OCI                 |
| **Step**     | 1                                  |
| **Topic**    | OCI Introduction & OCI Provider    |
| **Speaker**  | Malte Menkhoff                     |
| **Duration** | 30 minutes                         |

### Content
|                     |            |
| ------------------- | ---------- |
| Webinar Language    | German     |
| Content Language    | English    |
| Content Development | GitLab     |
| Content Deployment  | Micro-Site |
| Code Deployment     | ZIP-File   |

### Structure
| Duration | Sub-Duration | Topic                |
|----------|--------------|----------------------|
| 05min    |              | intro + big picture  |
| 20min    |              | content              |
|          | 05min        | general              |
|          | 05min        | VM/BM                |
|          | 05min        | Instance Groups      |
|          | 05min        | OKE                  |
| 05min    |              | q&a                  | 

### Pre-Requisite for Attendees
Kunden benötigen für das Ausprobieren des Codes im Nachgang einen Account in OCI - der folgende Link sollte jeweils gezeigt / geshared werden, damit die Kunden wissen, wie sie Zugang zu OCI erhalten:  
[How to get an account on OCI][oci_account]

### Intro
"7 steps to OCI" ist eine Programm, wo wir anhand von 7 einzelnen Webinaren zeigen, was die Oracle Cloud Infrastrcucture ist und wie man mit Hilfe von Terraform Infrastrukturen für Workloads aufbauen kann.  
Hierfür nutzen wir die Analogie eines Hotels, welche vom Inhalt her aufzeigen soll, wie man Schritt für Schritt von der Planung zu einem fertigen Betrieb für unzählige Applikationsgäste wird.  
Wir fangen an mit einer kurzen Einführung in OCI und wie man Terraform zur Automatisierung nutzen kann und gehen dann anschliessend daran ein Basis zu schaffen, um dann abschliessend Applikations- und Datenbank-Infrastruktur bereitzustellen.
Dabei nutzen wir ein git-basiertes Repository, welches neben einer Beschreibung der Schritte ebenfalls gleich den Code beinhaltet, den jeder Teilnehmer im Anschluss selbstständig in einem Free-Tier ausprobieren und testen kann.  
Die Webinare sind hierbei jeweils in 30 Minuten unterteilt und erklären auf sich aufbauend wie man Schritt für Schritt zu einer Umgebung für Ihren Service kommen.  

Heute ist der dritte Teil dieser Webinar-Serie - wir werden jeweils in einem Abstand von 2 Wochen für die weiteren Schritte dann jeweils einladen sowie den Code hier bereitstellen.  
Den Link zu den vorherigen Teilen finden Sie jeweils hier: 
[Übersicht][home]
  
Damit Sie den gezeigten Inhalt auch nachvollziehen könnten gibt es als Vorraussetzung, dass Sie einen Account auf OCI sich erstellen - wie das funktioniert findet Sie hier:  
[How to get an account on OCI][oci_account]

### Analogie
(Die Analogie wird mit Hilfe eines Videos gezeigt, wobei der Inhalt währenddessen zu beschreiben ist)
| Schritt   | Titel             | Analogie          | Beschreibung                                                                                                                          | 
|---------- | ----------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | Intro & Provider  | Bauplanung        | Wir zeigen wie ein Hotel funktioniert und wie man ein Hotel aufbauen kann                                                             |   
| 2         | Base              | Gebäude           | Wir bauen das Gebäude, die Aussenanlage sowie Aufzüge und alles was für den Betrieb notwendig ist                                     |   
| 3         | DB-Infra          | Spa-Bereich       | Wir bauen den Spa-Bereich als USP von OCI, um die Gäste rundum zu verwöhnen                                                           | 
| 4         | App-Infra         | Restaurant        | Wir schaffen die Basis für die Gäste für das kulinarische Wohl                                                                        |
| 5         | Workload          | Zimmer            | Wir stellen die Innenbereiche der Zimmer fertig mit Bett, Badewanne sowie Entertainment-System                                        |
| 6         | Governance        | Rezeption         | Wir bauen die Rezeption und stellen alles dafür bereit, dass die Gäste einen einfachen Check-in und -out haben                        |
| 7         | Vizualizer        | Marketing         | Wir erstellen die Website und starten eine Marketing-Kampagnen, welches es jeden Gast ermöglicht einfach uns zu finden und zu buchen  |

### Schritt 4 "App-Infra"  
Im vierten Schritt beschäftigen wir uns mit dem Restaurant und wie die Gäste mit Essen und Getränken versorgt werden können.  
Hierbei zeigen wir die verschiedenen Wege die Applikations-Infrastruktur bereitzustellen von Instance Groups bis hin zu einem automatisierten Kubernetes Deployment.   
Am Ende der App-Infrastruktur hat jeder Teilnehmer gesehen wie VMs, BMS, Instanz-Gruppen sowie Kubernetes Cluster zu erstellen sind.  

<!--- Links -->
[oci_account]:       ../oci-account.md
[home]:             /README.md