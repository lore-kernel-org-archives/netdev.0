From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] man: ip-link: fix a typo
Date: Fri,  7 Nov 2014 03:57:05 +0900
Message-ID: <1415300225-18893-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48306 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbaKFS5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 13:57:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 man/man8/ip-link.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4ee1d62..6d32f5e 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -54,7 +54,7 @@ ip-link \- network device configuration
 .ti -8
 .IR TYPE " := [ "
 .BR bridge " | "
-.BR bond " ]"
+.BR bond " | "
 .BR can " | "
 .BR dummy " | "
 .BR hsr " | "
-- 
1.9.3
