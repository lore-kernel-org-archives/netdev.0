From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] netem: fix a typo in explain()
Date: Sat, 24 Dec 2011 05:39:13 +0100
Message-ID: <1324701553.2915.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53144 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab1LXEjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 23:39:18 -0500
Received: by wgbdr13 with SMTP id dr13so18215575wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 20:39:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_netem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index e9a601b..b1fd452 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -38,7 +38,7 @@ static void explain(void)
 "                 [ loss random PERCENT [CORRELATION]]\n" \
 "                 [ loss state P13 [P31 [P32 [P23 P14]]]\n" \
 "                 [ loss gemodel PERCENT [R [1-H [1-K]]]\n" \
-"                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
+"                 [ reorder PERCENT [CORRELATION] [ gap DISTANCE ]]\n");
 }
 
 static void explain1(const char *arg)
