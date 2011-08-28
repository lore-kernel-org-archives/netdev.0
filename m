From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH] iwlwifi: iwl-agn-rs.c: remove old comment
Date: Sun, 28 Aug 2011 08:22:38 -0500
Message-ID: <1314537758-19159-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: ilw@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: wey-yi.w.guy@intel.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this comment refers to some code that was removed.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 3789ff4..733bd38 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -2209,7 +2209,6 @@ static void rs_stay_in_table(struct iwl_lq_sta *lq_sta, bool force_search)
 
 /*
  * setup rate table in uCode
- * return rate_n_flags as used in the table
  */
 static void rs_update_rate_tbl(struct iwl_priv *priv,
 			       struct iwl_rxon_context *ctx,
-- 
1.7.5.4
