;;;; test.lisp
;;;;
;;;; This file is part of the cl-closure-template library, released under Lisp-LGPL.
;;;; See file COPYING for details.
;;;;
;;;; Author: Moskvitin Andrey <archimag@gmail.com>

(defpackage #:closure-template.test
  (:use #:cl #:iter #:lift #:closure-template)
  (:export #:run-closure-template-tests))

(in-package #:closure-template.test)

(deftestsuite closure-template-test () ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; expression parser tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftestsuite expression-parser-test (closure-template-test) ())

(addtest (expression-parser-test)
  expression-1
  (ensure-same '(:variable "var")
               (parse-expression " $var ")))

(addtest (expression-parser-test)
  expression-2
  (ensure-same '(+ (:variable "x") (:variable "y"))
               (parse-expression " $x + $y ")))

(addtest (expression-parser-test)
  expression-3
  (ensure-same '(:min (:variable "x") (:variable "y"))
               (parse-expression "min($x, $y)")))

(addtest (expression-parser-test)
  expression-4
  (ensure-same '(:min (:variable "x") (:max 5 (:variable "y")))
               (parse-expression "min($x, max(5, $y))")))


(addtest (expression-parser-test)
  expression-5
  (ensure-same "Hello world"
               (parse-expression "'Hello world'")))

(addtest (expression-parser-test)
  expression-6
  (ensure-same '(:variable "x" "y")
               (parse-expression "$x.y")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; template parser tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun parse-single-template (obj)
  (third (parse-template obj)))

(deftestsuite template-parser-test (closure-template-test) ())

;;;; print

(addtest (template-parser-test)
  hello-name-template-1
  (ensure-same '(closure-template.parser:template ("helloName") "Hello "
                 (closure-template.parser:print-tag (:VARIABLE "name")))
               (parse-single-template "{template helloName}Hello {$name}{/template}")))

;;;; literal

(addtest (template-parser-test)
  literal-1
  (ensure-same '(closure-template.parser:template ("literal-test") 
                 (closure-template.parser:literal "Test {$x} {foreach $foo in $bar}{$foo}{/foreach}"))
               (parse-single-template "{template literal-test}{literal}Test {$x} {foreach $foo in $bar}{$foo}{/foreach}{/literal}{/template}")))

;;;; if

(addtest (template-parser-test)
  if-1
  (ensure-same '(closure-template.parser:template ("if-test")
                 (closure-template.parser:if-tag
                  ((:variable "x") ("Hello "
                                    (closure-template.parser:print-tag (:variable "x"))))))
               (parse-single-template "{template if-test}{if $x}Hello {$x}{/if}{/template}")))

(addtest (template-parser-test)
  if-2
  (ensure-same '(closure-template.parser:template ("if-test")
                 (closure-template.parser:if-tag
                  ((:variable "x") ("Hello " (closure-template.parser:print-tag (:variable "x"))))
                  (t ("Hello world"))))
               (parse-single-template "{template if-test}{if $x}Hello {$x}{else}Hello world{/if}{/template}")))

(addtest (template-parser-test)
  if-3
  (ensure-same '(closure-template.parser:template ("if-test")
                 (closure-template.parser:if-tag
                  ((:variable "x") ("Hello " (closure-template.parser:print-tag (:variable "x"))))
                  ((:variable "y") ("Hello " (closure-template.parser:print-tag (:variable "y"))))
                  (t ("Hello world"))))
               (parse-single-template "{template if-test}{if $x}Hello {$x}{elseif $y}Hello {$y}{else}Hello world{/if}{/template}")))

(addtest (template-parser-test)
  if-4
  (ensure-same '(closure-template.parser:template ("if-test")
                 (closure-template.parser:if-tag
                  ((:variable "x") ("Hello " (closure-template.parser:print-tag (:variable "x"))))
                  ((:variable "y") ("Hello " (closure-template.parser:print-tag (:variable "y"))))
                  ((:variable "z") ("By!"))
                  (t ("Hello world"))))
               (parse-single-template "{template if-test}{if $x}Hello {$x}{elseif $y}Hello {$y}{elseif $z}By!{else}Hello world{/if}{/template}")))

;;;; switch

(addtest (template-parser-test)
  switch-1
  (ensure-same '(closure-template.parser:template ("switch-test")
                 (closure-template.parser:switch-tag (:variable "x")
                  nil
                  ((1) ("hello world"))
                  ((2 3 4) ("by-by"))))
               (parse-single-template "{template switch-test}{switch $x}{case 1}hello world{case 2, 3, 4}by-by{/switch}{/template}")))

(addtest (template-parser-test)
  switch-2
  (ensure-same '(closure-template.parser:template ("switch-test")
                 (closure-template.parser:switch-tag (:variable "x")
                  ("default value")
                  ((1) ("hello world"))
                  ((2 3 4) ("by-by"))))
               (parse-single-template "{template switch-test}{switch $x}{case 1}hello world{case 2, 3, 4}by-by{default}default value{/switch}{/template}")))

;;;; foreach

(addtest (template-parser-test)
  foreach-1
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:foreach ((:variable "x") (:variable "y" "foo"))
                  ((closure-template.parser:print-tag (:variable "x")))))
               (parse-single-template "{template test}{foreach $x in $y.foo }{$x}{/foreach}{/template}")))

;;;; for

(addtest (template-parser-test)
  for-1
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:for-tag ((:variable "x") (:range 10)) " ! "))
               (parse-single-template "{template test}{for $x in range(10)} ! {/for}{/template}")))

(addtest (template-parser-test)
  for-2
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:for-tag ((:variable "x") (:range 4 10)) " ! "))
               (parse-single-template "{template test}{for $x in range(4, 10)} ! {/for}{/template}")))

(addtest (template-parser-test)
  for-3
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:for-tag ((:variable "x") (:range 4 10 2)) " ! "))
               (parse-single-template "{template test}{for $x in range(4, 10, 2)} ! {/for}{/template}")))


;;;; call

(addtest (template-parser-test)
  call-1
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:call "hello-name" (:variable "x")))
               (parse-single-template "{template test}{call hello-name data=\"$x\" /}{/template}")))

(addtest (template-parser-test)
  call-2
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:call "hello-name" nil
                  (closure-template.parser:param (:variable "name") (:variable "x"))))
               (parse-single-template "{template test}{call hello-name}{param name: $x /}{/call}{/template}")))


(addtest (template-parser-test)
  call-3
  (ensure-same '(closure-template.parser:template ("test")
                 (closure-template.parser:call "hello-name" (:variable "data")
                  (closure-template.parser:param (:variable "a") (:variable "x"))
                  (closure-template.parser:param (:variable "b") nil
                   "Hello " (closure-template.parser:print-tag (:variable "y")))))
               (parse-single-template "{template test}{call hello-name data=\"$data\"}{param a: $x /}{param b}Hello {$y}{/param} {/call}{/template}")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; common-lisp-backend test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftestsuite common-lisp-backend-test (closure-template-test) ()
  (:run-setup :once-per-test-case )
  (:dynamic-variables *default-translate-package*)
  (:setup (setf *default-translate-package*
                (make-template-package :closute-template.test.templates)))
  (:teardown (delete-package :closute-template.test.templates)))

(addtest (common-lisp-backend-test)
  hello-world
  (ensure-same "Hello world"
               (progn
                (compile-template :common-lisp-backend
                                  "{template hello-world}Hello world{/template}")
                (funcall (find-symbol "HELLO-WORLD" :closute-template.test.templates)))))
            
(addtest (common-lisp-backend-test)
  hello-name
  (ensure-same "Hello Closure Template"
               (progn
                (compile-template :common-lisp-backend
                                  "{template hello-name}Hello {$name}{/template}")
                (funcall (find-symbol "HELLO-NAME" :closute-template.test.templates)
                         '(:name "Closure Template")))))

;;;; dotted variables

(addtest (common-lisp-backend-test)
  dotted-vars-1
  (ensure-same "Hello world"
               (progn
                (compile-template :common-lisp-backend
                                  "{template dotted}{$obj.first} {$obj.second}{/template}")
                (funcall (find-symbol "DOTTED" :closute-template.test.templates)
                         '(:obj (:first "Hello" :second "world"))))))

;;;; if

(addtest (common-lisp-backend-test)
  if-1
  (ensure-same '("Hello Andrey" "")
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{if $name}Hello {$name}{/if}{/template}")
                (list (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:name "Andrey"))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               nil)))))

(addtest (common-lisp-backend-test)
  if-2
  (ensure-same '("Hello Andrey" "Hello Guest")
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}Hello {if $name}{$name}{else}Guest{/if}{/template}")
                (list (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:name "Andrey"))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               nil)))))

(addtest (common-lisp-backend-test)
  if-3
  (ensure-same '("Hello Andrey" "By Masha" "Thank Vasy" "Guest?")
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{if $hello}Hello {$hello}{elseif $by}By {$by}{elseif $thank}Thank {$thank}{else}Guest?{/if}{/template}")
                (list (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:hello "Andrey"))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:by "Masha"))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:thank "Vasy"))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               nil)))))

;;;; switch

(addtest (common-lisp-backend-test)
  switch-1
  (ensure-same '("Variant 1: 0" "Variant 2: Hello" "Miss!" "Variant 2: 2")
               (progn
                 (compile-template :common-lisp-backend
                                   "{template test}{switch $var}{case 0}Variant 1: {$var}{case 1, 'Hello', 2}Variant 2: {$var}{default}Miss!{/switch}{/template}")
                 (list (funcall (find-symbol "TEST" :closute-template.test.templates)
                                '(:var 0))
                       (funcall (find-symbol "TEST" :closute-template.test.templates)
                                '(:var "Hello"))                       
                       (funcall (find-symbol "TEST" :closute-template.test.templates)
                                nil)
                       (funcall (find-symbol "TEST" :closute-template.test.templates)
                                '(:var 2))))))
               
;;;; foreach

(addtest (common-lisp-backend-test)
  foreach-1
  (ensure-same " alpha beta gamma"
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{foreach $opernand in $opernands} {$opernand}{/foreach}{/template}")
                (funcall (find-symbol "TEST" :closute-template.test.templates)
                         '(:opernands ("alpha" "beta" "gamma"))))))

(addtest (common-lisp-backend-test)
  foreach-2
  (ensure-same '(" alpha beta gamma"  "Hello world")
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{foreach $opernand in $opernands} {$opernand}{ifempty}Hello world{/foreach}{/template}")
                (list (funcall (find-symbol "TEST" :closute-template.test.templates)
                               '(:opernands ("alpha" "beta" "gamma")))
                      (funcall (find-symbol "TEST" :closute-template.test.templates)
                               nil)))))

;;;; for

(addtest (common-lisp-backend-test)
  for-1
  (ensure-same " 0 1 2 3 4"
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{for $i in range(5)} {$i}{/for}{/template}")
                (funcall (find-symbol "TEST" :closute-template.test.templates)))))

(addtest (common-lisp-backend-test)
  for-2
  (ensure-same "456789"
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{for $i in range(4, 10)}{$i}{/for}{/template}")
                (funcall (find-symbol "TEST" :closute-template.test.templates)))))

(addtest (common-lisp-backend-test)
  for-3
  (ensure-same "147"
               (progn
                (compile-template :common-lisp-backend
                                  "{template test}{for $i in range($from, $to, $by)}{$i}{/for}{/template}")
                (funcall (find-symbol "TEST" :closute-template.test.templates)
                         '(:from 1 :to 10 :by 3)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Run all tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun run-closure-template-tests (&optional (test 'closure-template-test))
  "Run all closure-template tests"
  (run-tests :suite test :report-pathname nil))









