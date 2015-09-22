From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man tc-htb: Fix HRB -> HTB typo
Date: Tue, 22 Sep 2015 20:01:13 +0300
Message-ID: <1442941273-4529-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33580 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756639AbbIVREh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 13:04:37 -0400
Received: by wiclk2 with SMTP id lk2so203189357wic.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 10:04:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Changed HRB -> HTB.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/tc-htb.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-htb.8 b/man/man8/tc-htb.8
index d196ecd..95f25de 100644
--- a/man/man8/tc-htb.8
+++ b/man/man8/tc-htb.8
@@ -48,7 +48,7 @@ Shaping works as documented in
 .B tc-tbf (8).
 
 .SH CLASSIFICATION
-Within the one HRB instance many classes may exist. Each of these classes
+Within the one HTB instance many classes may exist. Each of these classes
 contains another qdisc, by default 
 .BR tc-pfifo (8).
 
-- 
2.4.2
