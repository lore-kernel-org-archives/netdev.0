From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 01/10] net: flow: Correct spelling of action
Date: Mon, 29 Dec 2014 11:15:31 +0900
Message-ID: <1419819340-19000-2-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59857 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaL2CP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:15:56 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so16454046pab.18
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:15:55 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only

Previously submitted individually to John Fastabend and netdev ML.
---
 include/uapi/linux/if_flow.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 598c009..25a6b31 100644
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
