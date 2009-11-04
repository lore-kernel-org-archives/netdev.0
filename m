From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] ignore gdb/patch related files
Date: Wed,  4 Nov 2009 09:26:33 -0500
Message-ID: <1257344795-8665-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46054 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474AbZKDOZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 09:25:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 .gitignore |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index 8199aae..5a3d20f 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,5 +1,12 @@
 Config
+.gdbinit
+.gdb_history
 *.o
 *.a
 *.so
+*.gdb
 *~
+*.diff
+*.patch
+*.orig
+*.rej
-- 
1.6.5.1

