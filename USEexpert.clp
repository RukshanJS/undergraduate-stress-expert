;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Undergraduate Stress Expert
;;
;; Created on Mon Oct 10 2022
;;
;; Copyright (c) 2022 - Rukshan J. Senanayaka
;; All rights reserved.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
(import javax.swing.*)
(import java.awt.*)
(import java.awt.event.*)

;; Don't clear defglobals on (reset)
(set-reset-globals FALSE)

(defglobal ?*crlf* = "
")

;; Main window
(defglobal ?*frame* = (new JFrame "Undergraduate Stress Expert"))
(?*frame* setDefaultCloseOperation (get-member JFrame EXIT_ON_CLOSE))
(?*frame* setSize 800 600)
(?*frame* setLocation 300 100)
(?*frame* setVisible TRUE)

;; Question field
(defglobal ?*qfield* = (new JTextArea 5 40))
(bind ?scroll (new JScrollPane ?*qfield*))
((?*frame* getContentPane) add ?scroll)
(?*qfield* setText "Please wait...")

;; Answer area
(defglobal ?*apanel* = (new JPanel))
(defglobal ?*afield* = (new JTextField 20))
(defglobal ?*afield-ok* = (new JButton OK))
(defglobal ?*afield-yes* = (new JButton Yes))
(defglobal ?*afield-no* = (new JButton No))
(defglobal ?*afield-quit* = (new JButton Exit))

((?*frame* getContentPane) add ?*apanel* (get-member BorderLayout SOUTH))
(?*frame* validate)
(?*frame* repaint)

(bind ?handler (new jess.awt.ActionListener answer-input-submit (engine)))
(?*afield-ok* addActionListener ?handler)

(bind ?handler (new jess.awt.ActionListener answer-input-yes (engine)))
(?*afield-yes* addActionListener ?handler)

(bind ?handler (new jess.awt.ActionListener answer-input-no (engine)))
(?*afield-no* addActionListener ?handler)

(bind ?handler (new jess.awt.ActionListener answer-input-quit (engine)))
(?*afield-quit* addActionListener ?handler)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate user
  (slot gpa (default 0))
)

(deftemplate question
  (slot text)
  (slot type)
  (multislot valid)
  (slot ident))

(deftemplate answer
  (slot ident)
  (slot text))

(deftemplate recommendation
  (slot solution)
  (slot explanation))

(deffacts question-data
  "The questions the system can ask."
  (question (ident demotivated) (type yes-no)
            (text "Are you feeling demotivated?"))
  (question (ident tired) (type yes-no)
            (text "Are you feeling tired throughout day?"))
  (question (ident mood) (type yes-no)
            (text "Are you having a bad mood throughout day?"))
  (question (ident no-desire) (type yes-no)
            (text "Do you have no desire to do anything?"))
  (question (ident lazy) (type yes-no)
            (text "Do you feel lazy throughout the day?"))
  (question (ident no-focus) (type yes-no)
            (text "Can't you focus during class?"))
  (question (ident suicidal) (type yes-no)
            (text "Are you suicidal?"))
  (question (ident aca-stress) (type yes-no)
            (text "Do you have academic stress?"))
  (question (ident gpa) (type number)
            (text "What is your GPA?"))
  (question (ident perform-friends) (type yes-no)
            (text "Do you not perform well as friends?"))
  (question (ident time-social) (type yes-no)
            (text "Are you spend >2 hours daily on social media?"))
  (question (ident low-esteem) (type yes-no)
            (text "Are you with low self esteem?"))
  (question (ident anxious) (type yes-no)
            (text "Do you regularly feel anxious?"))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module ask
(defmodule ask)

(deffunction ask-user (?question ?type ?valid)
  "Ask a question, and return the answer"
  (?*apanel* removeAll)
  (?*qfield* setText ?question)
  (if (eq ?type multi) then
    (?*acombo* removeAllItems)
    (?*apanel* add ?*acombo*)
    (?*apanel* add ?*acombo-ok*)
    
    (foreach ?item ?valid
             (?*acombo* addItem ?item)
    )
    else
    (if (eq ?type yes-no) then
      (?*apanel* add ?*afield-yes*)
      (?*apanel* add ?*afield-no*)
      (?*frame* validate)
      (?*frame* repaint)
    else
      (?*apanel* add ?*afield*)
      (?*apanel* add ?*afield-ok*)
      (?*afield* setText "")
      (?*frame* validate)
      (?*frame* repaint)
    )
  )
)

(deffunction is-of-type (?answer ?type ?valid)
  "Check that the answer has the right form"
  (if (eq ?type multi) then
    (foreach ?item ?valid
             (if (eq (sym-cat ?answer) (sym-cat ?item)) then
               (return TRUE)))
    (return FALSE))
    
  (if (eq ?type number) then
    (return (is-a-number ?answer)))
    
  ;; plain text
  (return (> (str-length ?answer) 0))
)

(deffunction is-a-number (?value)
  (try
   (integer ?value)
   (return TRUE)
   catch 
   (return FALSE))
)

(defrule ask::ask-question-by-id
  "Given the identifier of a question, ask it"
  (declare (auto-focus TRUE))
  (MAIN::question (ident ?id) (text ?text) (valid $?valid) (type ?type))
  (not (MAIN::answer (ident ?id)))
  (MAIN::ask ?id)
  =>
  (ask-user ?text ?type ?valid)
  ((engine) waitForActivations)
)

(defrule ask::collect-user-input
  "Check an answer returned from the GUI, and optionally return it"
  (declare (auto-focus TRUE))
  (MAIN::question (ident ?id) (text ?text) (type ?type) (valid $?valid))
  (not (MAIN::answer (ident ?id)))
  ?user <- (user-input ?input)
  ?ask <- (MAIN::ask ?id)
  =>
  (if (is-of-type ?input ?type ?valid) then
    (retract ?ask ?user)
    (assert (MAIN::answer (ident ?id) (text ?input)))
    (return)
    else
    (retract ?ask ?user)
    (assert (MAIN::ask ?id)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module interview
(defmodule interview)

(defrule request-demotivated
  (declare (salience 100))
  =>
  (assert (ask demotivated))
)
(defrule request-tired
  (declare (salience 100))
  =>
  (assert (ask tired))
)
(defrule request-mood
  (declare (salience 100))
  =>
  (assert (ask mood))
)
(defrule request-no-desire
  (declare (salience 500))
  =>
  (assert (ask no-desire))
)
(defrule request-lazy
  (declare (salience 100))
  =>
  (assert (ask lazy))
)
(defrule no-focus
  (declare (salience 100))
  =>
  (assert (ask no-focus))
)
(defrule suicidal
  (declare (salience 700))
  =>
  (assert (ask suicidal))
)
(defrule aca-stress
  =>
  (assert (ask aca-stress))
)
(defrule gpa
  ; If experience academic stress, ask GPA.
  (answer (ident aca-stress) (text ?t&:(eq ?t yes)))
  =>
  (assert (ask gpa))
)
(defrule assert-user-fact
  (answer (ident gpa) (text ?i))
  =>
  (assert (user (gpa ?i)))
)
(defrule perform-friends
  =>
  (assert (ask perform-friends))
)
(defrule time-social
  ; If feel not perform as well as friends.
  (answer (ident perform-friends) (text ?t&:(eq ?t yes)))
  =>
  (assert (ask time-social))
)
(defrule low-esteem
  =>
  (assert (ask low-esteem))
)
(defrule anxious
  =>
  (assert (ask anxious))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module recommend
(defmodule recommend)

(defrule combine-recommendations
  ?r1 <- (recommendation (solution ?f) (explanation ?e1))
  ?r2 <- (recommendation (solution ?f) (explanation ?e2&:(neq ?e1 ?e2)))
  =>
  (retract ?r2)
  (modify ?r1 (explanation (str-cat ?e1 ?*crlf* ?e2)))
)

(defrule solution-eatwell
  (answer (ident demotivated) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Eat well")
           (explanation "when feel always demotivated")))
)
(defrule solution-eatwell-no-desire
  (answer (ident no-desire) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Eat well")
           (explanation "when you have no desire to do anything")))
)
(defrule solution-sleepwell-lazy
  (answer (ident lazy) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Sleep well")
           (explanation "when feel lazy throughout the day")))
)
(defrule solution-sleepwell-no-focus
  (answer (ident no-focus) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Sleep well")
           (explanation "when can't focus in class")))
)
(defrule solution-sleepwell-tired
  (answer (ident tired) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Sleep well")
           (explanation "when feel tired throughout day")))
)
(defrule solution-aca-stress
  (answer (ident aca-stress) (text yes))
  (user (gpa ?i&:(> ?i 3.7)))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "not overthink")
           (explanation "when feel academic stress and you already have a first class")))
)
(defrule solution-aca-stress-2nd-upper
  (answer (ident aca-stress) (text yes))
  (user (gpa ?i&:(and (> ?i 3.3) (< ?i 3.7))))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "work harder to get a first class without worrying")
           (explanation "when feel academic stress due to not getting a first class")))
)
(defrule solution-aca-stress-2nd-lower
  (answer (ident aca-stress) (text yes))
  (user (gpa ?i&:(and (> ?i 3.0) (< ?i 3.3))))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "work harder to get a second upper class without worrying")
           (explanation "when feel academic stress due to not getting a 2nd upper")))
)
(defrule solution-aca-stress-low-gpa
  (answer (ident aca-stress) (text yes))
  (user (gpa ?i&:(< ?i 3.0)))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "talk to your academic advisor")
           (explanation "when GPA is less than 3.0")))
)
(defrule solution-perform-friends-social
  (answer (ident perform-friends) (text yes))
  (answer (ident time-social) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "avoid distractions by installing an app such as https://offtime.app")
           (explanation "when distracted by social media")))
)
(defrule solution-perform-friends-no-social
  (answer (ident perform-friends) (text yes))
  (answer (ident time-social) (text no))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "not compare yourself to others. Try to compare yourself to who you were yesterday, not someone else today.")
           (explanation "when feel inadequate")))
)
(defrule solution-exercise-low-esteem
  (answer (ident low-esteem) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "exercise at least half an hour a day")
           (explanation "when regularly feel low self esteem")))
)
(defrule solution-exercise-anxious
  (answer (ident anxious) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "exercise at least half an hour a day")
           (explanation "when regularly feel anxious")))
)
(defrule solution-exercise-mood
  (answer (ident mood) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "exercise at least half an hour a day")
           (explanation "when regularly have a bad mood")))
)
(defrule solution-exercise-demotivated
  (answer (ident demotivated) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "exercise at least half an hour a day")
           (explanation "when regularly feel demotivated")))
)
(defrule solution-exercise-demotivated
  (answer (ident demotivated) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "exercise at least half an hour a day")
           (explanation "when regularly feel demotivated")))
)
(defrule solution-immediate-visit
  (declare (salience 700))
  (answer (ident suicidal) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "Immediately visit counseling center")
           (explanation "you are not alone and the world is a beautiful place and you just need someone to talk to")))
)
(defrule solution-suicidal
  (answer (ident suicidal) (text yes))
  =>
  (assert (solution-given yes))
  (assert (recommendation
           (solution "call your closest friend immediately and explain your situation.")
           (explanation "when feel sucidical, or think you are better off dead")))
)
(defrule default-rule
  (declare (salience -100))
  (not (solution-given yes))
  =>
  (assert (recommendation
           (solution "Consult a real counsellor")
           (explanation "I cannot help you")))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module report
(defmodule report)

(defrule sort-and-print
  (declare (salience 100))
  ?r1 <- (recommendation (solution ?f1) (explanation ?e))
  (not (recommendation (solution ?f2&:(< (str-compare ?f2 ?f1) 0))))
  =>
  (printout t "*** I recommend you " ?f1 crlf crlf)
  (printout t "Explanation: "  ?e crlf crlf)

  ; Output the results into the window
  (bind ?myText (str-cat (?*qfield* getText) ?*crlf* "*** I recommend you to " "[" ?f1 "]" ?*crlf* "Because," ?*crlf* ?e ", it is best to " ?f1 ?*crlf*))
  (?*qfield* setText ?myText)

  (?*apanel* removeAll)
  (?*apanel* add ?*afield-quit*)
  (?*frame* validate)
  (?*frame* repaint)
  
  (retract ?r1)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Input handlers
(deffunction answer-input-submit (?EVENT)
  "An event handler for the user input field"
  (?*qfield* setText "")
  (if (eq (?*afield* getText) "") then
  (assert (ask::user-input (sym-cat (?*acombo* getSelectedItem))))
  else
  (assert (ask::user-input (sym-cat (?*afield* getText))))
  )
)
(deffunction answer-input-yes (?EVENT)
  "An event handler for the user yes button"
  (?*qfield* setText "")
  (assert (ask::user-input (sym-cat "yes")))
)
(deffunction answer-input-no (?EVENT)
  "An event handler for the user no button"
  (?*qfield* setText "")
  (assert (ask::user-input (sym-cat "no")))
)
(deffunction answer-input-quit (?EVENT)
  "An event handler for to quit the program"
  (exit)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Driver
(deffunction run-system ()
  (reset)
  (focus interview recommend report)
  (run)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Program entry point
(run-system)

