module Frontend.IR

import Data.Vect

%default total

record Buf (rank : Nat) where
  constructor MkBuf
  name : String

record Aff (loopRank : Nat) where
  constructor MkAff
  c : Integer
  a : Vect loopRank Integer

Idx : (loopRank : Nat) -> (tensorRank : Nat) -> Type
Idx loopRank tensorRank = Vect tensorRank (Aff loopRank)

data Expr : (loopRank : Nat) -> Type where
  F32 : Double -> Expr loopRank
  Load : {tensorRank : Nat} -> Buf tensorRank -> Idx loopRank tensorRank -> Expr loopRank
  Add : Expr loopRank -> Expr loopRank -> Expr loopRank
  Mul : Expr loopRank -> Expr loopRank -> Expr loopRank

data Stmt : (loopRank : Nat) -> Type where
  Assign : {tensorRank : Nat} -> Buf tensorRank -> Idx loopRank tensorRank -> Expr loopRank -> Stmt loopRank
  ReduceAdd : {tensorRank : Nat} -> Buf tensorRank -> Idx loopRank tensorRank -> Expr loopRank -> Stmt loopRank

data LoopNest : (loopRank : Nat) -> Type where
  Block : List (Stmt loopRank) -> LoopNest loopRank
  For : Aff loopRank -> Aff loopRank -> LoopNest (S loopRank) -> LoopNest loopRank

data AnyBuf : Type where
  MkAnyBuf : {rank : Nat} -> Buf rank -> AnyBuf

record Kernel where
  constructor MkKernel
  name : String
  symbols : List String
  args : List AnyBuf
  body : LoopNest 0
