From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH 2/2] Update .gitignore
Date: Sat, 26 May 2012 21:02:35 +0200
Message-ID: <1338058955-5789-3-git-send-email-jengelh@inai.de>
References: <20120526180654.GB31938@1984>
 <1338058955-5789-1-git-send-email-jengelh@inai.de>
Cc: netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1338058955-5789-1-git-send-email-jengelh@inai.de>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 .gitignore     |    1 +
 src/.gitignore |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index 928e44b..f7a5fc7 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,5 +1,6 @@
 .deps/
 .libs/
+.dirstamp
 Makefile
 Makefile.in
 *.o
diff --git a/src/.gitignore b/src/.gitignore
index 6e6763d..55a0d27 100644
--- a/src/.gitignore
+++ b/src/.gitignore
@@ -1,5 +1,6 @@
 /conntrack
 /conntrackd
+/nfct
 
 /read_config_lex.c
 /read_config_yy.c
-- 
1.7.7

