#!/bin/bash

whoami

cd /usr/share/vim/vim74/syntax

cat <<"EOF" | patch -R
--- /usr/share/vim/vim73/syntax/javascript.vim	2012-10-16 19:57:21.000000000 -0400
+++ javascript.vim	2012-10-16 19:56:57.000000000 -0400
@@ -34,8 +34,8 @@
 syn match   javaScriptCommentSkip      "^[ \t]*\*\($\|[ \t]\+\)"
 syn region  javaScriptComment	       start="/\*"  end="\*/" contains=@Spell,javaScriptCommentTodo
 syn match   javaScriptSpecial	       "\\\d\d\d\|\\."
-syn region  javaScriptStringD	       start=+"+  skip=+\\\\\|\\"\|\\\n+  end=+"\|$+	contains=javaScriptSpecial,@htmlPreproc
-syn region  javaScriptStringS	       start=+'+  skip=+\\\\\|\\'\|\\\n+  end=+'\|$+	contains=javaScriptSpecial,@htmlPreproc
+syn region  javaScriptStringD	       start=+"+  skip=+\\\\\|\\"+  end=+"\|$+	contains=javaScriptSpecial,@htmlPreproc
+syn region  javaScriptStringS	       start=+'+  skip=+\\\\\|\\'+  end=+'\|$+	contains=javaScriptSpecial,@htmlPreproc
 
 syn match   javaScriptSpecialCharacter "'\\.'"
 syn match   javaScriptNumber	       "-\=\<\d\+L\=\>\|0[xX][0-9a-fA-F]\+\>"
EOF
