#lang typed/racket/base
(require "expression-structs.rkt"
         "lexical-structs.rkt"
         "helpers.rkt"
         racket/list)

(provide find-toplevel-variables)


(: find-toplevel-variables (ExpressionCore -> (Listof Symbol)))
;; Collects the list of toplevel variables we need.
(define (find-toplevel-variables exp)
  (: loop (ExpressionCore -> (Listof Symbol)))
  (define (loop exp)
    (cond
      [(Top? exp)
       (list-difference (Prefix-names (Top-prefix exp))
                        (loop (Top-code exp)))]
      [(Constant? exp)
       empty]
            
      [(Var? exp)
       (list (Var-id exp))]
            
      [(Def? exp)
       (cons (Def-variable exp)
             (loop (Def-value exp)))]
      
      [(Branch? exp)
       (append (loop (Branch-predicate exp))
               (loop (Branch-consequent exp))
               (loop (Branch-alternative exp)))]
      
      [(Lam? exp)
       (list-difference (loop (Lam-body exp))
                        (Lam-parameters exp))]
      [(Seq? exp)
       (apply append (map loop (Seq-actions exp)))]
      
      [(App? exp)
       (append (loop (App-operator exp))
               (apply append (map loop (App-operands exp))))]))
  
  (unique/eq? (loop exp)))
  