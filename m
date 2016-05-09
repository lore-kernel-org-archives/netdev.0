From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net PATCH v2 1/1] export tc ife uapi header
Date: Mon,  9 May 2016 08:05:06 -0400
Message-ID: <1462795506-19509-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:32769 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbcEIMFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 08:05:16 -0400
Received: by mail-io0-f174.google.com with SMTP id f89so169474842ioi.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 05:05:15 -0700 (PDT)
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
