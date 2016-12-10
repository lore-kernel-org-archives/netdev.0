From: kushwaha.a@samsung.com
Subject: [PATCH] net: socket: removed an unnecessary newline
Date: Sat, 10 Dec 2016 11:14:47 +0530
Message-ID: <1481348687-23904-1-git-send-email-kushwaha.a@samsung.com>
Cc: netdev@vger.kernel.org, akkushwaha9896@gmail.com
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:37723 "EHLO
        mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbcLJFrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 00:47:09 -0500
Received: from epcpsbgm1new.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OHY00QK3G2JTPC0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Sat, 10 Dec 2016 14:47:07 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kushwaha <kushwaha.a@samsung.com>

This patch removes a newline which was added
in socket.c file in net-next

Signed-off-by: Amit Kushwaha <kushwaha.a@samsung.com>
---
 net/socket.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index 5835383..dc01d7b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1,4 +1,3 @@
-
 /*
  * NET		An implementation of the SOCKET network access protocol.
  *
-- 
1.7.9.5
