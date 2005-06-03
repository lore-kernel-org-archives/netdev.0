From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/4] [PKT_SCHED] Fix typo in NET_EMATCH_STACK help text
Date: Fri, 03 Jun 2005 23:12:42 +0200
Message-ID: <20050603211315.521247000@axs>
References: <20050603211241.593114000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=fix_ematch_kconfig_typo
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Spotted by Geert Uytterhoeven <geert@linux-m68k.org>.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: ematch/net/sched/Kconfig
===================================================================
--- ematch.orig/net/sched/Kconfig
+++ ematch/net/sched/Kconfig
@@ -405,7 +405,7 @@ config NET_EMATCH_STACK
 	---help---
 	  Size of the local stack variable used while evaluating the tree of
 	  ematches. Limits the depth of the tree, i.e. the number of
-	  encapsulated precedences. Every level requires 4 bytes of addtional
+	  encapsulated precedences. Every level requires 4 bytes of additional
 	  stack space.
 
 config NET_EMATCH_CMP
