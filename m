From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/44] drivers/net/wireless/iwlwifi: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:36 -0800
Message-ID: <6beaab935c2c511a5833e855db527976ef05e2dc.1289789604.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index c2636a7..f293fb6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2420,7 +2420,7 @@ static const char *desc_lookup(u32 num)
 	max = ARRAY_SIZE(advanced_lookup) - 1;
 	for (i = 0; i < max; i++) {
 		if (advanced_lookup[i].num == num)
-			break;;
+			break;
 	}
 	return advanced_lookup[i].name;
 }
-- 
1.7.3.1.g432b3.dirty
