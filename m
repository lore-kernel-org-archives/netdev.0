From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ss: Fix 'Kuznetosv' -> 'Kuznetsov' typo
Date: Sat,  3 Jan 2015 12:07:49 +0200
Message-ID: <1420279669-3491-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:61567 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbACKSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 05:18:08 -0500
Received: by mail-lb0-f177.google.com with SMTP id b6so15421099lbj.22
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 02:18:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ss.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index f4b709b..450649a 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -190,7 +190,7 @@ List all the tcp sockets in state FIN-WAIT-1 for our apache to network 193.233.7
 
 .SH AUTHOR
 .I ss 
-was written by Alexey Kuznetosv, <kuznet@ms2.inr.ac.ru>.
+was written by Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>.
 .PP
 This manual page was written by Michael Prokop <mika@grml.org>
 for the Debian project (but may be used by others).
-- 
2.1.3
