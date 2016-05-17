From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 7/7] mwifiex: fix typo
Date: Tue, 17 May 2016 16:38:46 +0200
Message-ID: <1463495926-13728-8-git-send-email-Julia.Lawall@lip6.fr>
References: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463495926-13728-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

firmare -> firmware

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/marvell/mwifiex/pcie.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index 0c7937e..9246ce8 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -2804,7 +2804,7 @@ static int mwifiex_pcie_request_irq(struct mwifiex_adapter *adapter)
 }
 
 /*
- * This function get firmare name for downloading by revision id
+ * This function gets the firmware name for downloading by revision id
  *
  * Read revision id register to get revision id
  */
