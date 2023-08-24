


module monad_mod
   type,abstract::monad
      character(len=114)::val=""
   contains
      procedure(unwrap_in),deferred::unwrap
   end type monad

   abstract interface
      character(len=114) function unwrap_in(this)result(res)
         import monad
         class(monad),intent(inout)::this
      end function unwrap_in

      function mfunc(str)result(res)
         import monad
         character(len=*),intent(in)::str
         class(monad),allocatable::res
      end function mfunc

      function fp()result(res)
         import monad
         class(monad),allocatable::res
      end function fp
   end  interface

   type,extends(monad)::MonadInput
   contains
      procedure,pass::unwrap=>unwrap_input
   end type MonadInput

   type,extends(monad)::MonadOutput
   contains
      procedure,pass::unwrap=>unwrap_output
   end type MonadOutput
   
   type,extends(monad)::MonadBind
        procedure(fp),pointer,nopass::lambda
   contains
      procedure,pass::unwrap=>unwrap_bind
   end type MonadBind
contains
   character(len=114) function unwrap_input(this)result(res)
      class(monadinput),intent(inout)::this
      read(*,"(A)")res
   end function unwrap_input

   character(len=114) function unwrap_output(this)result(res)
      class(monadoutput),intent(inout)::this
      write(*,"(g0)")this%val
      res="Nothing"
   end function unwrap_output

   character(len=114) function unwrap_bind(this)result(res)
      class(MonadBind),intent(inout)::this
      class(monad),allocatable::m
      m=this%lambda()
      res=m%unwrap()
   end function unwrap_bind


   function pure_input(str)result(res)
      character(len=*),intent(in)::str
      class(monad),allocatable::res
      res=monadinput()
   end function pure_input

   function pure_output(str)result(res)
      character(len=*),intent(in)::str
      class(monad),allocatable::res
      res=monadoutput(str)
   end function pure_output

   function mbind(this,func)result(res)
      class(monad),intent(inout)::this
      procedure(mfunc)::func
      class(monad),allocatable::res
      !res=Monadbind(lambda=fptr)
      res=Monadbind()
      select type(res)
      type is (monadbind)
         res%lambda=>fptr
      end select
   contains
      function fptr()result(res)
         class(monad),allocatable::res
         res=func(this%unwrap())
      end function fptr
   end function mbind
end module monad_mod


program main
   use monad_mod
   implicit none
   class(monad),allocatable::m1,m2,m3
   procedure(mfunc),pointer::ptr_in,ptr_out
   ptr_in =>fin
   ptr_out=>fout
   m1=pure_output("Hello")
   m2=mbind(m1,ptr_in)
   m3=mbind(m2,ptr_out)
   !write(*,*)m3%unwrap()
contains
    function fin(str)result(res)
        character(len=*),intent(in)::str
        class(monad),allocatable::res
        res=pure_input("")
    end function fin

    function fout(str)result(res)
        character(len=*),intent(in)::str
        class(monad),allocatable::res
        res=pure_output("Nice to meet You")
    end function fout
end program main
