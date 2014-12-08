From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH flow-net-next] net: flow: Correct spelling of action
Date: Mon,  8 Dec 2014 10:14:55 +0900
Message-ID: <1418001295-2389-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:62358 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbaLHBQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2014 20:16:00 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so3832394pdb.38
        for <netdev@vger.kernel.org>; Sun, 07 Dec 2014 17:16:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/uapi/linux/if_flow.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 25aa744..9255990 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -356,7 +356,7 @@ enum {
  * @uid unique identifier for flow
  * @priority priority to execute flow match/action in table
  * @match null terminated set of match uids match criteria
- * @actoin null terminated set of action uids to apply to match
+ * @action null terminated set of action uids to apply to match
  *
  * Flows must match all entries in match set.
  */
-- 
2.1.3
