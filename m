From: Richard Guy Briggs <rgb@tricolour.ca>
Subject: [PATCH] xfrm: fix header file comment reference to struct xfrm_replay_state_esn
Date: Thu,  8 Sep 2016 13:55:56 -0400
Message-ID: <1473357356-31064-1-git-send-email-rgb@tricolour.ca>
Cc: Richard Guy Briggs <rgb@tricolour.ca>, paul@nohats.ca
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reported-by: Paul Wouters <paul@nohats.com>
Signed-off-by: Richard Guy Briggs <rgb@tricolour.ca>
---
 include/uapi/linux/xfrm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 1433389..1fc62b2 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -298,7 +298,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
-	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_state_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
 	XFRMA_PROTO,		/* __u8 */
 	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
-- 
2.1.4
