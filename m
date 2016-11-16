From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 v2 1/9] man: ip-l2tp.8: fix l2spec_type documentation
Date: Wed, 16 Nov 2016 22:45:18 +0000
Message-ID: <20161116224526.32343-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:52014 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941449AbcKPWql (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 17:46:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 man/man8/ip-l2tp.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 5b7041f..4a3bb20 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -239,7 +239,7 @@ find in received L2TP packets. Default is to use no cookie.
 set the layer2specific header type of the session.
 .br
 Valid values are:
-.BR none ", " udp "."
+.BR none ", " default "."
 .TP
 .BI offset " OFFSET"
 sets the byte offset from the L2TP header where user data starts in
-- 
2.10.2
