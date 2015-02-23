From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next 1/1] net: sched: export tc_connmark.h so it is uapi accessible
Date: Mon, 23 Feb 2015 08:17:12 -0500
Message-ID: <1424697432-10573-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:43464 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbbBWNR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 08:17:27 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so20721639iga.1
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 05:17:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/tc_act/Kbuild |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 19d5219..242cf0c 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -9,3 +9,4 @@ header-y += tc_pedit.h
 header-y += tc_skbedit.h
 header-y += tc_vlan.h
 header-y += tc_bpf.h
+header-y += tc_connmark.h
-- 
1.7.9.5
