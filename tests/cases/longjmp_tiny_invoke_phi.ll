; ModuleID = '/tmp/emscripten_temp/src.cpp.o'
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32-S128"
target triple = "i386-pc-linux-gnu"

@_ZL3buf = internal global [20 x i16] zeroinitializer, align 2
@.str = private unnamed_addr constant [13 x i8] c"hello world\0A\00", align 1
@.str1 = private unnamed_addr constant [6 x i8] c"more\0A\00", align 1
@.str2 = private unnamed_addr constant [6 x i8] c"fair\0A\00", align 1

define i32 @main() {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval
  %call = invoke i32 @setjmp(i16* getelementptr inbounds ([20 x i16]* @_ZL3buf, i32 0, i32 0)) returns_twice
          to label %allgood unwind label %awful

allgood:
  %p = phi i32 [0, %entry], [1, %if.else]
  %calll = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([6 x i8]* @.str2, i32 0, i32 0))
  %total = add i32 %p, %call
  %tobool = icmp ne i32 %total, 10
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call1 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([13 x i8]* @.str, i32 0, i32 0))
  call void @longjmp(i16* getelementptr inbounds ([20 x i16]* @_ZL3buf, i32 0, i32 0), i32 10)
  br label %if.end

if.else:                                          ; preds = %entry
  %call2 = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([6 x i8]* @.str1, i32 0, i32 0))
  %chak = icmp ne i32 %call2, 1337
  br i1 %chak, label %if.end, label %allgood

if.end:                                           ; preds = %if.else, %if.then
  ret i32 0

awful:
  %Z = landingpad { i8*, i32 } personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*)
       cleanup
  ret i32 1
}

declare i32 @setjmp(i16*) returns_twice

declare i32 @printf(i8*, ...)

declare void @longjmp(i16*, i32)

declare i32 @__gxx_personality_v0(...)

