From: Andrey Mazo <mazo@telum.ru>
Subject: [PATCH 2/4] bridge-utils: Remove unused variable in doc/Makefile.in
Date: Mon, 24 Feb 2014 14:56:44 +0400
Message-ID: <1393239406-8504-3-git-send-email-mazo@telum.ru>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Cc: Andrey Mazo <mazo@telum.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:50888 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbaBXLCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 06:02:34 -0500
In-Reply-To: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andrey Mazo <mazo@telum.ru>
---
 doc/Makefile.in | 2 --
 1 file changed, 2 deletions(-)

diff --git a/doc/Makefile.in b/doc/Makefile.in
index 23bfb06..df5a1a7 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -10,8 +10,6 @@ bindir=@bindir@
 sbindir=@sbindir@
 mandir=@mandir@
 
-SUBDIRS=libbridge brctl
-
 all:
 
 clean:
-- 
1.8.4.5
