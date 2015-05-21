From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH trivial] enic: Grammar s/an negative/a negative/
Date: Thu, 21 May 2015 14:09:14 +0200
Message-ID: <1432210154-22047-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/cisco/enic/enic_clsf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index 6739ebc08c473f7a..a31b57adcb372917 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -15,7 +15,7 @@
  *	@rq: rq number to steer to
  *
  * This function returns filter_id(hardware_id) of the filter
- * added. In case of error it returns an negative number.
+ * added. In case of error it returns a negative number.
  */
 int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 {
-- 
1.9.1
