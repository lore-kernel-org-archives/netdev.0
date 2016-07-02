From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 1/1] iproute2: unmangle netdev/my emails in man pages (hfsc, stab)
Date: Sat,  2 Jul 2016 13:03:12 +0200
Message-ID: <1467457392-15402-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:48834 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbcGBLDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jul 2016 07:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No other man pages do so, hiding netdev is kind of silly and I don't
mind having my own address normally visible.
---
 man/man7/tc-hfsc.7 | 4 ++--
 man/man8/tc-hfsc.8 | 4 ++--
 man/man8/tc-stab.8 | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/man7/tc-hfsc.7 b/man/man7/tc-hfsc.7
index ca04961..5ae5e6b 100644
--- a/man/man7/tc-hfsc.7
+++ b/man/man7/tc-hfsc.7
@@ -555,8 +555,8 @@ Please refer to \fBtc\-stab\fR(8)
 .
 \fBtc\fR(8), \fBtc\-hfsc\fR(8), \fBtc\-stab\fR(8)
 
-Please direct bugreports and patches to: <net...@vger.kernel.org>
+Please direct bugreports and patches to: <netdev@vger.kernel.org>
 .
 .SH "AUTHOR"
 .
-Manpage created by Michal Soltys (sol...@ziu.info)
+Manpage created by Michal Soltys (soltys@ziu.info)
diff --git a/man/man8/tc-hfsc.8 b/man/man8/tc-hfsc.8
index 5444118..fd0df8f 100644
--- a/man/man8/tc-hfsc.8
+++ b/man/man8/tc-hfsc.8
@@ -54,8 +54,8 @@ parameters, you will specify linear service curve.
 .
 \fBtc\fR(8), \fBtc\-hfsc\fR(7), \fBtc\-stab\fR(8)
 
-Please direct bugreports and patches to: <net...@vger.kernel.org>
+Please direct bugreports and patches to: <netdev@vger.kernel.org>
 .
 .SH "AUTHOR"
 .
-Manpage created by Michal Soltys (sol...@ziu.info)
+Manpage created by Michal Soltys (soltys@ziu.info)
diff --git a/man/man8/tc-stab.8 b/man/man8/tc-stab.8
index 02caa7d..03a0659 100644
--- a/man/man8/tc-stab.8
+++ b/man/man8/tc-stab.8
@@ -156,8 +156,8 @@ it's good to use \fBethtool\fR to turn off offloading features.
 .br
 \fB[2]\fR http://www.faqs.org/rfcs/rfc2684.html
 
-Please direct bugreports and patches to: <net...@vger.kernel.org>
+Please direct bugreports and patches to: <netdev@vger.kernel.org>
 .
 .SH "AUTHOR"
 .
-Manpage created by Michal Soltys (sol...@ziu.info)
+Manpage created by Michal Soltys (soltys@ziu.info)
-- 
2.1.3
