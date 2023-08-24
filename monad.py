class Monad:
    def __init__(self,data):
        self.data=data

    def unpack(self):
        pass

class MonadInput(Monad):
    def unpack(self):
        return input()

class MonadOutput(Monad):
    def unpack(self):
        args,kwargs=self.data
        return print(*args,**kwargs)

class MonadBind(Monad):
    def unpack(self):
        print(self.data)
        return self.data().unpack()

#monad     :: Monad a
#function  :: a -> Monad b
#return    :: Monad b

def bind(monad,function):
    return MonadBind(lambda : function(monad.unpack()))

def pure_input():
    return MonadInput(None)

def pure_output(*args,**kwargs):
    return MonadOutput((args,kwargs))

def pure_hello():
    mhint  =pure_output("Your Name")
    minput =bind(mhint , lambda _:pure_input())
    moutput=bind(minput, lambda name:pure_output("hello",name))
    return moutput
pure_hello().unpack()
