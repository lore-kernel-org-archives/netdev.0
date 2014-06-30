From: vadimk <vadim4j@gmail.com>
Subject: [PATCH] ip: Added missing usage for netconf object
Date: Mon, 30 Jun 2014 17:37:50 +0300
Message-ID: <1404139070-14177-1-git-send-email-vadim4j@gmail.com>
Cc: vadimk <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:49510 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaF3OoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 10:44:24 -0400
Received: by mail-la0-f51.google.com with SMTP id mc6so4908140lab.38
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 07:44:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 ip/ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ip.c b/ip/ip.c
index 813fabd..739b88d 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -45,7 +45,7 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | tcp_metrics | token }\n"
+"                   netns | l2tp | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
-- 
2.0.1
