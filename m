From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 2/2] Add Jiri Pirko as TC subsystem co-maintainer
Date: Tue, 18 Apr 2017 21:24:00 -0400
Message-ID: <1492565040-29102-2-git-send-email-jhs@emojatatu.com>
References: <1492565040-29102-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36559 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758879AbdDSBYM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 21:24:12 -0400
Received: by mail-io0-f194.google.com with SMTP id x86so1967181ioe.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:24:12 -0700 (PDT)
In-Reply-To: <1492565040-29102-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 749bd84..a9df81e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -12190,6 +12190,7 @@ F:	kernel/taskstats.c
 TC subsystem
 M:	Jamal Hadi Salim <jhs@mojatatu.com>
 M:	Cong Wang <xiyou.wangcong@gmail.com>
+M:	Jiri Pirko <jiri@resnulli.us>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	include/net/pkt_cls.h
-- 
1.9.1
