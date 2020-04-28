#lang racket

;; The X86_0 language:
;; Reg   => rsp | rbp | rax | rbx | rcx | rdx | rsi | rdi
;;       |  r8 | r9 | r10 | r11 | r12 | r13 | r14 | r15
;; Arg   => (int Int) | (reg Reg) | (deref Reg Int) | (var Name)
;; Instr => (addq Arg Arg) | (subq Arg Arg) | (movq Arg Arg)
;;       |  (retq) | (negq Arg) | (callq Label) | (pushq Arg)
;;       |  (popq Arg)
;; Block => (block Info Instr ..1)
;; X86_0 => (program Info ((Label . Block) ..1))

;; Translate (roughly) C0 toX86_0.
