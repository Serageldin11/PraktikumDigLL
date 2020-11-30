import 'dart:async';
import 'dart:html';
import 'dart:convert';

//variablen
List qua = new List();
List path = new List();
var antList = [];
var findex = 0; //fragen index
var erg = 0;
bool next = false;
List<Fragen> fragenObjs;
List<Dropdown> dropDownObjs;
var i = 0; //progressbar
var witdh = 0; //startbreite progressbar

void main() {
  var fragenObjsJson = jsonDecode(arrayObjsText)['fragen'] as List;
  fragenObjs =
      fragenObjsJson.map((fragenJson) => Fragen.fromJson(fragenJson)).toList();

  var dropdownObjsJson = jsonDecode(dropDownJson)['wahlen'] as List;
  dropDownObjs = dropdownObjsJson
      .map((dropdownJson) => Dropdown.fromJson(dropdownJson))
      .toList();

  if (fragenObjs[0].type == 0) {}
  //print(dropDownObjs[0].antworten[2]['choice']);
  weiterButton(11);
}

weiterButton(int frid) async {
  reset();
  progress(frid);

  for (int i = 0; i < fragenObjs.length; i++) {
    if (fragenObjs[i].id == frid) {
      querySelector('#frage').innerHtml = fragenObjs[i].text;

      var backbutton =
          ButtonElement(); //Button um zur letzten Frage zu springen
      backbutton.innerText = 'zurück';
      backbutton.id = 'backbutton';
      List selectArr = []; //Arrays für die Dropdowns
      List checkAntw = []; //Array für bool ob checkboxen checked sind

      if (fragenObjs[i].type == 1) {
        //Checkbox
        for (int l = 0; l < dropDownObjs.length; l++) {
          if (dropDownObjs[l].id == fragenObjs[i].id) {
            for (int g = 0; g < dropDownObjs[l].antworten.length; g++) {
              var namid = 'check' + g.toString();
              checkAntw.add(false);
              var check = CheckboxInputElement();
              check.name = namid;
              check.id = namid;
              check.onClick.listen((event) {
                checkAntw[g] = !checkAntw[g];
              });
              var lab = LabelElement();
              lab.htmlFor = namid;
              lab.text = dropDownObjs[l].antworten[g]["choice"];

              querySelector('#antwortmöglichkeiten').children.add(check);
              querySelector('#antwortmöglichkeiten').children.add(lab);
              querySelector('#antwortmöglichkeiten').children.add(BRElement());
            }
            ;

            var wbutton = ButtonElement();
            wbutton.innerText = 'weiter';
            wbutton.id = 'wbutton';

            querySelector('#antwortmöglichkeiten').children.add(backbutton);
            querySelector('#antwortmöglichkeiten').children.add(wbutton);
            querySelector('#wbutton').onClick.listen((event) {
              for (int k = 0; k < dropDownObjs[l].antworten.length; k++) {
                if (checkAntw[k] == true) {}
                ;
                antwortWahl(
                    fragenObjs[i].id, k, fragenObjs[i].antworten[k]['next']);
                path.add(fragenObjs[i].id);
              }
            });
          }
          ;
        }
        ;
      } else if (fragenObjs[i].type == 2) {
        //Dropdown
        for (int l = 0; l < dropDownObjs.length; l++) {
          if (dropDownObjs[l].id == fragenObjs[i].id) {
            for (int j = 0; j < dropDownObjs[l].count; j++) {
              //count = Anzahl an Dropdowns
              selectArr.add(SelectElement());
              selectArr[j].name = 'dropdown' + j.toString();
              selectArr[j].className = 'dd';

              for (int g = 0; g < dropDownObjs[l].antworten.length; g++) {
                var opt =
                    OptionElement(data: dropDownObjs[l].antworten[g]['choice']);
                selectArr[j].append(opt);
              }
              ;

              querySelector('#antwortmöglichkeiten').children.add(selectArr[j]);

              var wbutton = ButtonElement();
              wbutton.innerText = 'weiter';
              wbutton.id = 'wbutton';

              if (j == dropDownObjs[l].count - 1) {
                querySelector('#antwortmöglichkeiten').children.add(backbutton);
                querySelector('#antwortmöglichkeiten').children.add(wbutton);
                querySelector('#wbutton').onClick.listen((event) {
                  for (int k = 0; k < dropDownObjs[l].count; k++) {
                    antwortWahl(
                        fragenObjs[i].id,
                        selectArr[k].selectedIndex,
                        fragenObjs[i].antworten[selectArr[k].selectedIndex]
                            ['next']);
                    path.add(fragenObjs[i].id);
                    print(selectArr[k].selectedIndex);
                  }
                });
              }
            }
          }
          ;
        }
        ;
      } else {
        for (int j = 0; j < fragenObjs[i].antworten.length; j++) {
          //Normal
          var button = ButtonElement();
          button.innerText = fragenObjs[i].antworten[j]['text'];
          button.id = 'a' + j.toString();
          button.className = 'button';
          querySelector('#antwortmöglichkeiten').children.add(button);

          var feedback = DivElement();
          feedback.setInnerHtml(fragenObjs[i].antworten[j]['feedback'],
              treeSanitizer: NodeTreeSanitizer.trusted);
          feedback.id = 'feedback';
          var wbutton = ButtonElement();
          wbutton.innerText = 'weiter';
          wbutton.id = 'wbutton';
          var zbutton = ButtonElement();
          zbutton.innerText = 'zurück';
          zbutton.id = 'zbutton';

          querySelector("#a" + j.toString()).onClick.listen((event) {
            reset();
            querySelector('#antwortmöglichkeiten').children.add(feedback);
            querySelector('#antwortmöglichkeiten').children.add(zbutton);
            querySelector('#antwortmöglichkeiten').children.add(wbutton);

            querySelector('#zbutton').onClick.listen((event) {
              //Button um vom Feedback zur Frage zurück zu kehren

              weiterButton(
                  i + 1); //i+1 weil fragenObjs bei 0 anfangen und ids bei 1
            });
            querySelector('#wbutton').onClick.listen((event) {
              antwortWahl(
                  fragenObjs[i].id, j, fragenObjs[i].antworten[j]['next']);
              path.add(fragenObjs[i].id);
            });
          });
        }
        querySelector('#antwortmöglichkeiten').children.add(backbutton);
      }

      querySelector('#backbutton').onClick.listen((event) {
        backButton();
      });
    }
  }
}

progress(id) {
  id = ((100 / fragenObjs.length) * id).round();
  if (i == 0) {
    i = 1;
    var elem = querySelector('#bar');
    var timer;
    frame() {
      if (witdh == id) {
        timer.cancel();
        i = 0;
      } else if (witdh < id) {
        witdh++;
        var w = witdh.toString();
        elem.style.width = w + '%';
        elem.innerHtml = w + '%';
      } else {
        witdh--;
        var w = witdh.toString();
        elem.style.width = w + '%';
        elem.innerHtml = w + '%';
      }
    }

    const oneSec = const Duration(milliseconds: 10);
    timer = new Timer.periodic(oneSec, (Timer t) => frame());
  }
}

backButton() {
  for (int i = path.length - 1; i >= 0; i--) {
    if (path[i] != 0) {
      weiterButton(path[i]);

      path[i] = 0;
      break;
    }
  }
}

antwortWahl(int id, int wahl, int next) {
  antList.add([id, wahl]);

  if (next == 0) {
    ergebnis();
  }
  weiterButton(next);
}

ergebnis() {
  reset();
  querySelector('#fragenfeld').children.clear();
  var erghead = HeadingElement.h2();
  erghead.text = 'Deine Auswahl';
  querySelector('#fragenfeld').children.add(erghead);

  for (int i = 0; i < antList.length; i++) {
    for (int j = 0; j < fragenObjs.length; j++) {
      if (fragenObjs[j].id == antList[i][0]) {
        var ergebnis = DivElement();
        ergebnis.text =
            fragenObjs[j].antworten[antList[i][1]]['wahl'].toString();
        querySelector('#fragenfeld').children.add(ergebnis);
      }
    }
  }
}

reset() {
  querySelector('#antwortmöglichkeiten').children.clear();
}

class Fragen {
  String text;
  List antworten;
  int id;
  int type;

  Fragen(this.text, this.antworten, this.id, this.type);

  factory Fragen.fromJson(dynamic json) {
    return Fragen(json['text'] as String, json['antworten'] as List,
        json['id'] as int, json['type'] as int);
  }

  @override
  String toString() {
    return '{ ${this.text}, ${this.antworten}, ${this.id}, ${this.type}}';
  }
}

class Dropdown {
  List antworten;
  int id;
  int count;

  Dropdown(this.antworten, this.id, this.count);

  factory Dropdown.fromJson(dynamic json) {
    return Dropdown(
        json['antworten'] as List, json['id'] as int, json['count'] as int);
  }

  @override
  String toString() {
    return '{${this.antworten}, ${this.id}, ${this.count}}';
  }
}

//auch für checkbox
String dropDownJson = '''{
  "wahlen" : [
  {
    "antworten":[
      {
        "wahl": 1,
        "choice":"Modul 1"
      },
      {
        "wahl": 2,
        "choice":"Modul 2"
      },
      {
        "wahl": 3,
        "choice":"Modul 3"
      }
    ],
    "id": 10,
    "count": 4
    },
    {
      "antworten":[
        {
          "wahl": 1,
          "choice":"Modul 1"
        },
        {
          "wahl": 2,
          "choice":"Modul 2"
        },
        {
          "wahl": 3,
          "choice":"Modul 3"
        }
      ],
      "id": 11,
      "type": 2,
      "count": 3
      },
    {
      "antworten":[
        {
          "wahl": 1,
          "choice":"Java"
        },
        {
          "wahl": 2,
          "choice":"C/C++"
        },
        {
          "wahl": 3,
          "choice":"Python"
        }
      ],
      "id": 15,
      "count": 1
      }
  ]
}''';

String arrayObjsText = '''{
  "fragen" : [
    {
      "text":"Erste Schritte",
      "antworten":[
        {
          "wahl": 0,
          "text":"Was ist eine Bachelorarbeit?",
          "next": 1,
          "feedback": "Die Bachelothesis ist ein Text mit dem Sie nachweisen sollen, dass Sie ein vorgegebenes Thema mit den erlernten Verfahren und Techniken ihres Studiengebietes bearbeiten können."
        },
        {
          "wahl": 1,
          "text":"Themenfindung",
          "next": 2,
          "feedback": "Die Themenfindung ist der erste Schritt bei einer Bacherlorarbeit. Im folgenden finden Sie einige Hinweise die dabei helfen."
        },
        {
          "wahl": 2,
          "text":"Antwort c",
          "next": 2,
          "feedback": "Feedback3"
        }
      ],
      "id": 1
      },
      {
        "text":"Themenfindung?",
        "antworten":[
          {
            "wahl": 0,
            "text":"Wie finde ich ein Thema?",
            "next": 3,
            "feedback": "Das Thema sollte zu Ihren Interessen und Fähigkeiten passen. Möchten sie ein Thema in der Softwareentwicklung oder lieber richtung E-learning? <br> Brainstormen Sie hierzu. Was möchten Sie rausfinden? Nutzen sie aktuelle Themen, lesen Sie aktuelle Fachartikel und populärwissenschaftliche Veröffentlichungen oder recherchieren sie im Web oder in der Bibliothek. Reden sie mit Ihren Praxisbetreuern, Dozenten, Kommilitonen, Freunden und Verwandten, oder holen Sie sich inspiration auf Konferenzen. <a href=\\"https://lernen.h-da.de/course/view.php?id=11311\\">Konferenzen</a>"
          },
          {
            "wahl": 1,
            "text":"Welche Themen darf ich bearbeiten?",
            "next": 3,
            "feedback": "Sie dürfen alle Themen aus allen Themenbereichen bearbeiten, die sie im Studium vermittelt bekommen haben."
          },
          {
            "wahl": 2,
            "text":"Welche Themengebiete sind nicht geeignet?",
            "next": 3,
            "feedback": "Themen welche zu komplex oder zu simpel sind. Die Bachelothesis ist ein Text.Im Rahmen einer Bachelorthesis sollen sie nachweisen, dass Sie ein vorgegebenes Thema mit den erlernten Verfahren und Techniken ihres Studiengebietes bearbeiten können.  Der Praxisanteil ist Grundlage für den auszuformulierenden Text."
          },
          {
            "wahl": 3,
            "text":"Beispielthemen",
            "next": 3,
            "feedback": "Semantic Web </p> Nutzung der Maschinellen Übersetzung für die Übersetzung in Leichte Sprache </p> Erprobung weiterer Methoden zur Extraktion von Terminologie und zur Indexierung </p> Implementierung von Regeln für die automatische Prüfung auf Wissenschaftlichkeit in der Sprache in LanguageTool."
          }
        ],
        "id": 2
        },
        {
        "text":"Soll die Arbeit in einem Betrieb oder an der Hochschule geschrieben werden?",
        "antworten":[
          {
            "wahl": 0,
            "text":"Betrieb",
            "next": 5,
            "feedback": "Feedback1"
          },
          {
            "wahl": 1,
            "text":"Hochschule",
            "next": 4,
            "feedback": "Feedback2"
          }
        ],
        "id": 3
        },
        {
          "text":"Hochschulfragen?",
          "antworten":[
            {
              "wahl": 0,
              "text":"Antwort a",
              "next": 5,
              "feedback": "Feedback1"
            },
            {
              "wahl": 1,
              "text":"Antwort b",
              "next": 5,
              "feedback": "Feedback2"
            },
            {
              "wahl": 2,
              "text":"Antwort c",
              "next": 5,
              "feedback": "Feedback3"
            }
          ],
          "id": 4
          },
          {
            "text":"Ergibt sich aus dem Praktikum ein Themenvorschlag?",
            "antworten":[
              {
                "wahl": 0,
                "text":"Ja",
                "next": 6,
                "feedback": "Feedback1"
                
              },
              {
                "wahl": 1,
                "text":"Nein",
                "next": 6,
                "feedback": "Feedback2"
              }
            ],
            "id": 5
            },
            {
              "text":"Gibt es im Betrieb einen qualifizierten Betreuer? (mindestens einen Bachelor)",
              "antworten":[
                {
                  "wahl": 0,
                  "text":"Ja",
                  "next": 7,
                  "feedback": "Feedback1"
                },
                {
                  "wahl": 1,
                  "text":"Nein",
                  "next": 7,
                  "feedback": "Feedback2"
                }
              ],
              "id": 6
              },
              {
                "text":"Tendierst Du eher zur Programmierung/Entwicklung von Systemen oder nicht ?",
                "antworten":[
                  {
                    "wahl": 0,
                    "text":"Ja",
                    "next": 8,
                    "feedback": "Feedback1"
                  },
                  {
                    "wahl": 1,
                    "text":"Nein",
                    "next": 8,
                    "feedback": "Feedback2"
                  }
                ],
                "id": 7
                },
                {
                  "text":"Hast Du selbst ein Ziel mit der Bachelorarbeit?",
                  "antworten":[
                    {
                      "wahl": 0,
                      "text":"Ich möchte wissenschaftlich arbeiten",
                      "next": 9,
                      "feedback": "Feedback1"
                    },
                    {
                      "wahl": 1,
                      "text":"Ich möchte neue Technologie lernen",
                      "next": 9,
                      "feedback": "Feedback2"
                    },
                    {
                      "wahl": 2,
                      "text":"Ich möchte bestehende Kenntnisse vertiefen",
                      "next": 9,
                      "feedback": "Feedback3"
                    },
                    {
                      "wahl": 3,
                      "text":"Ich möchte die  Ergebnisse aus dem Praktikum nutzen und in eine Arbeit überführen",
                      "next": 9,
                      "feedback": "Feedback3"
                    },
                    {
                      "wahl": 4,
                      "text":"Ich möchte ein privates Projekt als Bachelorarbeit bearbeiten",
                      "next": 9,
                      "feedback": "Feedback3"
                    },
                    {
                      "wahl": 5,
                      "text":"Nein, ich habe kein Ziel",
                      "next": 9,
                      "feedback": "Feedback3"
                    }
                  ],
                  "id": 8
                  },
                  {
                    "text":"Was kannst Du? (EINORDNUNG)",
                    "antworten":[
                      {
                        "wahl": 0,
                        "text":"Programmiere",
                        "next": 10,
                        "feedback": "Feedback1"
                      },
                      {
                        "wahl": 1,
                        "text":"gut gestalten (Adobe … )",
                        "next": 10,
                        "feedback": "Feedback2"
                      },
                      {
                        "wahl": 2,
                        "text":"gut Filme machen",
                        "next": 10,
                        "feedback": "Feedback3"
                      }
                    ],
                    "id": 9
                    },
                    {
                      "text":"Gibt es ein Fach im Studium, dass Dir besonderen Spaß gemacht hat? Nenne deine drei Lieblingsfächer im Studium",
                      "antworten":[
                        {
                          "wahl": 0,
                          "text":"Antwort a",
                          "next": 11,
                          "feedback": "Feedback1"
                        },
                        {
                          "wahl": 1,
                          "text":"Antwort b",
                          "next": 11,
                          "feedback": "Feedback2"
                        },
                        {
                          "wahl": 2,
                          "text":"Antwort c",
                          "next": 11,
                          "feedback": "Feedback3"
                        }
                      ],
                      "id": 10,
                      "type": 1
                      },
                      {
                        "text":"Nenne Deine drei Fächer im Studium, die Dir am wenigsten Spaß gemacht haben",
                        "antworten":[
                          {
                            "wahl": 0,
                            "text":"Antwort a",
                            "next": 12,
                            "feedback": "Feedback1"
                          },
                          {
                            "wahl": 1,
                            "text":"Antwort b",
                            "next": 12,
                            "feedback": "Feedback2"
                          },
                          {
                            "wahl": 2,
                            "text":"Antwort c",
                            "next": 12,
                            "feedback": "Feedback3"
                          }
                        ],
                        "id": 11,
                        "type": 2
                        },
                        {
                          "text":"Welche praktische Erfahrung mit Rechnern hast Du?",
                          "antworten":[
                            {
                              "wahl": 0,
                              "text":"Unix",
                              "next": 13,
                              "feedback": "Feedback1"
                            },
                            {
                              "wahl": 1,
                              "text":"Windows",
                              "next": 13,
                              "feedback": "Feedback2"
                            },
                            {
                              "wahl": 2,
                              "text":"MacOS",
                              "next": 13,
                              "feedback": "Feedback3"
                            },
                            {
                              "wahl": 3,
                              "text":"App Entwicklung",
                              "next": 13,
                              "feedback": "Feedback3"
                            },
                            {
                              "wahl": 4,
                              "text":"Web Entwicklung",
                              "next": 13,
                              "feedback": "Feedback3"
                            }
                          ],
                          "id": 12
                          },
                          {
                            "text":"Welche der folgenden Titel von bereits gelaufenen Bachelorthesen findest Du interessant?",
                            "antworten":[
                              {
                                "wahl": 0,
                                "text":"10 Titel",
                                "next": 14,
                                "feedback": "Feedback1"
                              },
                              {
                                "wahl": 1,
                                "text":"Antwort b",
                                "next": 14,
                                "feedback": "Feedback2"
                              },
                              {
                                "wahl": 2,
                                "text":"Antwort c",
                                "next": 14,
                                "feedback": "Feedback3"
                              }
                            ],
                            "id": 13
                            },
                            {
                              "text":"Welche der folgenden Arbeitsschwerpunkte findest Du interessant?",
                              "antworten":[
                                {
                                  "wahl": 0,
                                  "text":"Computergrafik und VR",
                                  "next": 15,
                                  "feedback": "Feedback1"
                                },
                                {
                                  "wahl": 1,
                                  "text":"Multimedia, Webanwendungen, App Entwicklung und Audioprogrammierung",
                                  "next": 15,
                                  "feedback": "Feedback2"
                                },
                                {
                                  "wahl": 2,
                                  "text":"E-Learning",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 3,
                                  "text":"IT-Sicherheit",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 4,
                                  "text":"Programmierung",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 5,
                                  "text":"Machine Learning",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 6,
                                  "text":"Mensch Computer Interaktion",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 7,
                                  "text":"Hardware Entwicklung mit Mikrocontrollern",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 8,
                                  "text":"Betriebssysteme",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                },
                                {
                                  "wahl": 9,
                                  "text":"Verteilte Systeme und Cloud Computing",
                                  "next": 15,
                                  "feedback": "Feedback3"
                                }
                              ],
                              "id": 14
                              },
                              {
                                "text":"In welcher Sprache möchtest Du die Arbeit schreiben?",
                                "antworten":[
                                  {
                                    "wahl": 0,
                                    "text":"Antwort a",
                                    "next": 16,
                                    "feedback": "Feedback1"
                                  },
                                  {
                                    "wahl": 1,
                                    "text":"Antwort b",
                                    "next": 16,
                                    "feedback": "Feedback2"
                                  },
                                  {
                                    "wahl": 2,
                                    "text":"Antwort c",
                                    "next": 16,
                                    "feedback": "Feedback3"
                                  }
                                ],
                                "id": 15,
                                "type": 2
                                },
                                {
                                  "text":"Möchtest Du in deiner Arbeit ein Programm/System entwickeln?",
                                  "antworten":[
                                    {
                                      "wahl": 0,
                                      "text":"Ja",
                                      "next": 17,
                                      "feedback": "Feedback1"
                                    },
                                    {
                                      "wahl": 1,
                                      "text":"Nein",
                                      "next": 17,
                                      "feedback": "Feedback2"
                                    }
                                  ],
                                  "id": 16
                                  },
                                  {
                                    "text":"Möchtest in deiner Arbeit eine Webseite entwickeln ?",
                                    "antworten":[
                                      {
                                        "wahl": 0,
                                        "text":"Ja",
                                        "next": 18,
                                        "feedback": "Feedback1"
                                      },
                                      {
                                        "wahl": 1,
                                        "text":"Nein",
                                        "next": 18,
                                        "feedback": "Feedback2"
                                      }
                                    ],
                                    "id": 17
                                    },
                                    {
                                      "text":"Möchtest Du deine Ergebnisse evaluieren?",
                                      "antworten":[
                                        {
                                          "wahl": 0,
                                          "text":"Ja",
                                          "next": 19,
                                          "feedback": "Feedback1"
                                        },
                                        {
                                          "wahl": 1,
                                          "text":"Nein",
                                          "next": 19,
                                          "feedback": "Feedback2"
                                        }
                                      ],
                                      "id": 18
                                      },
                                      {
                                        "text":"Möchtest Du am Konzept eines Systems arbeiten ?",
                                        "antworten":[
                                          {
                                            "wahl": 0,
                                            "text":"Ja",
                                            "next": 20,
                                            "feedback": "Feedback1"
                                          },
                                          {
                                            "wahl": 1,
                                            "text":"Nein",
                                            "next": 20,
                                            "feedback": "Feedback2"
                                          }
                                        ],
                                        "id": 19
                                        },
                                        {
                                          "text":"Möchtest Du an einer (Marketing)Strategie für ein Produkt/System arbeiten?",
                                          "antworten":[
                                            {
                                              "wahl": 0,
                                              "text":"Ja",
                                              "next": 21,
                                              "feedback": "Feedback1"
                                            },
                                            {
                                              "wahl": 1,
                                              "text":"Nein",
                                              "next": 21,
                                              "feedback": "Feedback2"
                                            }
                                          ],
                                          "id": 20
                                          },
                                          {
                                            "text":"Möchtest Du einen Themenbereich mit einer wissenschaftlichen Fragestellung untersuchen und darstellen?",
                                            "antworten":[
                                              {
                                                "wahl": 0,
                                                "text":"Ja",
                                                "next": 22,
                                                "feedback": "Feedback1"
                                              },
                                              {
                                                "wahl": 1,
                                                "text":"Nein",
                                                "next": 22,
                                                "feedback": "Feedback2"
                                              }
                                            ],
                                            "id": 21
                                            },
                                            {
                                              "text":"Abgrenzung: was möchtest auf keinen Fall machen? (Eingabefeld)",
                                              "antworten":[
                                                {
                                                  "wahl": 0,
                                                  "text":"Ja",
                                                  "next": 0,
                                                  "feedback": "Feedback1"
                                                },
                                                {
                                                  "wahl": 1,
                                                  "text":"Nein",
                                                  "next": 0,
                                                  "feedback": "Feedback2"
                                                }
                                              ],
                                              "id": 22
                                              }
                                
                      
        
]
}
''';
