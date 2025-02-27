; TEST-ARGS: -src-unroll=5 -tgt-unroll=5
; ERROR: Source is more defined than target

; https://bugs.llvm.org/show_bug.cgi?id=18223

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@b = common global i32 0, align 4
@d = common global i32 0, align 4
@f = common global i32 0, align 4
@c = common global i32 0, align 4
@h = common global i32 0, align 4
@.str = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @src() {
entry:
  store i32 0, ptr @b, align 4
  %0 = load i32, ptr @c, align 4
  %tobool = icmp eq i32 %0, 0
  br i1 %tobool, label %entry.split.us, label %entry.entry.split_crit_edge

entry.entry.split_crit_edge:                      ; preds = %entry
  br label %entry.split

entry.split.us:                                   ; preds = %entry
  br label %for.body.us

for.body.us:                                      ; preds = %for.inc.us, %entry.split.us
  %inc2.us = phi i32 [ 0, %entry.split.us ], [ %inc.us, %for.inc.us ]
  %storemerge1.us = phi i32 [ 0, %entry.split.us ], [ %inc.us, %for.inc.us ]
  %sub.us = add i32 %storemerge1.us, -1
  %cmp1.us = icmp uge i32 %sub.us, %inc2.us
  %conv.us = zext i1 %cmp1.us to i32
  br i1 true, label %for.inc.us, label %if.then.us

if.then.us:                                       ; preds = %for.body.us
  br label %for.inc.us

for.inc.us:                                       ; preds = %if.then.us, %for.body.us
  %inc.us = add nsw i32 %inc2.us, 1
  %cmp.us = icmp slt i32 %inc.us, 5
  br i1 %cmp.us, label %for.body.us, label %for.end_us_lcssa.us

for.end_us_lcssa.us:                              ; preds = %for.inc.us
  br label %for.end

entry.split:                                      ; preds = %entry.entry.split_crit_edge
  br label %for.body

for.body:                                         ; preds = %for.inc, %entry.split
  %inc2 = phi i32 [ 0, %entry.split ], [ %inc, %for.inc ]
  %storemerge1 = phi i32 [ 0, %entry.split ], [ %inc, %for.inc ]
  %sub = add i32 %storemerge1, -1
  %cmp1 = icmp uge i32 %sub, %inc2
  %conv = zext i1 %cmp1 to i32
  br i1 false, label %for.inc, label %if.then

if.then:                                          ; preds = %for.body
  store i32 0, ptr @h, align 4
  br label %for.inc

for.inc:                                          ; preds = %if.then, %for.body
  %inc = add nsw i32 %inc2, 1
  %cmp = icmp slt i32 %inc, 5
  br i1 %cmp, label %for.body, label %for.end_us_lcssa

for.end_us_lcssa:                                 ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.end_us_lcssa, %for.end_us_lcssa.us
  %inc.lcssa = phi i32 [ %inc, %for.end_us_lcssa ], [ %inc.us, %for.end_us_lcssa.us ]
  %conv.lcssa = phi i32 [ %conv, %for.end_us_lcssa ], [ %conv.us, %for.end_us_lcssa.us ]
  store i32 1, ptr @d, align 4
  store i32 %inc.lcssa, ptr @b, align 4
  store i32 %conv.lcssa, ptr @f, align 4
  %call = call i32 (ptr, ...) @myprintf(ptr getelementptr inbounds ([4 x i8], ptr @.str, i64 0, i64 0), i32 %conv.lcssa)
  ret i32 0
}

define i32 @tgt() {
entry:
  store i32 0, ptr @b, align 4
  %0 = load i32, ptr @c, align 4
  %tobool = icmp eq i32 %0, 0
  br i1 %tobool, label %entry.split.us, label %entry.entry.split_crit_edge

entry.entry.split_crit_edge:                      ; preds = %entry
  br label %entry.split

entry.split.us:                                   ; preds = %entry
  br label %for.body.us

for.body.us:                                      ; preds = %for.inc.us, %entry.split.us
  %inc2.us = phi i32 [ 0, %entry.split.us ], [ %inc.us, %for.inc.us ]
  br i1 true, label %for.inc.us, label %if.then.us

if.then.us:                                       ; preds = %for.body.us
  br label %for.inc.us

for.inc.us:                                       ; preds = %if.then.us, %for.body.us
  %inc.us = add nsw i32 %inc2.us, 1
  %exitcond = icmp ne i32 %inc.us, 5
  br i1 %exitcond, label %for.body.us, label %for.end_us_lcssa.us

for.end_us_lcssa.us:                              ; preds = %for.inc.us
  br label %for.end

entry.split:                                      ; preds = %entry.entry.split_crit_edge
  br label %for.body

for.body:                                         ; preds = %for.inc, %entry.split
  %inc2 = phi i32 [ 0, %entry.split ], [ %inc, %for.inc ]
  br i1 false, label %for.inc, label %if.then

if.then:                                          ; preds = %for.body
  store i32 0, ptr @h, align 4
  br label %for.inc

for.inc:                                          ; preds = %if.then, %for.body
  %inc = add nsw i32 %inc2, 1
  %exitcond3 = icmp ne i32 %inc, 5
  br i1 %exitcond3, label %for.body, label %for.end_us_lcssa

for.end_us_lcssa:                                 ; preds = %for.inc
  br label %for.end

for.end:                                          ; preds = %for.end_us_lcssa, %for.end_us_lcssa.us
  %inc.lcssa = phi i32 [ 5, %for.end_us_lcssa ], [ 5, %for.end_us_lcssa.us ]
  %conv.lcssa = phi i32 [ 1, %for.end_us_lcssa ], [ 1, %for.end_us_lcssa.us ]
  store i32 1, ptr @d, align 4
  store i32 %inc.lcssa, ptr @b, align 4
  store i32 %conv.lcssa, ptr @f, align 4
  %call = call i32 (ptr, ...) @myprintf(ptr getelementptr inbounds ([4 x i8], ptr @.str, i64 0, i64 0), i32 %conv.lcssa)
  ret i32 0
}

declare i32 @myprintf(ptr captures(none) readonly, ...)
