From: Gilles Espinasse <g.esp@free.fr>
Subject: [PATCH] iproute2: fix minor typo in comments
Date: Sun, 10 Jul 2011 17:45:37 +0200
Message-ID: <1310312737-2296-1-git-send-email-g.esp@free.fr>
Cc: Gilles Espinasse <g.esp@free.fr>
To: netdev@vger.kernel.org, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:39404 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755627Ab1GJPgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 11:36:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gilles Espinasse <g.esp@free.fr>
---
 README       |    2 +-
 README.devel |    2 +-
 configure    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/README b/README
index 0ed0372..528b539 100644
--- a/README
+++ b/README
@@ -21,7 +21,7 @@ database routines.  Often this is in the db-devel package.
 
 2. make
 
-The makefile will automatically build a file Config which
+The makefile will automatically build a Config file which
 contains whether or not ATM is available, etc.
 
 3. To make documentation, cd to doc/ directory , then
diff --git a/README.devel b/README.devel
index 2022869..9b7d11e 100644
--- a/README.devel
+++ b/README.devel
@@ -1,7 +1,7 @@
 Iproute2 development is closely tied to Linux kernel networking
 development. Most new features require a kernel and a utility component.
 
-Please submit both the the Linux networking mailing list
+Please submit both to the Linux networking mailing list
    <netdev@vger.kernel.org>
 
 The current source is in the git repository:
diff --git a/configure b/configure
index 600fa96..69797ab 100755
--- a/configure
+++ b/configure
@@ -65,7 +65,7 @@ then
 	return
 fi
 
-#check if we need dont our internal header ..
+#check if we dont need our internal header ..
 cat >/tmp/ipttest.c <<EOF
 #include <xtables.h>
 char *lib_dir;
-- 
1.5.6.5

