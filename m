From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/1] export tc ife uapi header
Date: Sat,  7 May 2016 09:19:59 -0400
Message-ID: <1462627199-10276-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:32914 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156AbcEGNUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 09:20:10 -0400
Received: by mail-ig0-f195.google.com with SMTP id rc4so7435971igc.0
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 06:20:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/tc_act/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index 242cf0c..e3969bd 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -10,3 +10,4 @@ header-y += tc_skbedit.h
 header-y += tc_vlan.h
 header-y += tc_bpf.h
 header-y += tc_connmark.h
+header-y += tc_ife.h
-- 
1.9.1
