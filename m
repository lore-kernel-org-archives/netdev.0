From: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
Subject: RE: [PATCH 2/3] atl1c: change author
Date: Thu, 1 Mar 2012 07:13:04 +0000
Message-ID: <7A9ADFFA56024346AAE90B6BABC3BD15D2F8A8@nasanexd02b.na.qualcomm.com>
References: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>,<1330580469-23348-3-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Ren, Cloud" <cjren@qca.qualcomm.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330580469-23348-3-git-send-email-cjren@qca.qualcomm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Um, actually, for now can you please use QCA or Qualcomm Atheros, Inc. QCA != Qualcomm.

  Luis
________________________________________
From: Ren, Cloud
Sent: Wednesday, February 29, 2012 9:41 PM
To: davem@davemloft.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Cc: qca-linux-team; nic-devel; Ren, Cloud
Subject: [PATCH 2/3] atl1c: change author

The author, jie yang, has left. please use nic-devel@qualcomm.com report bugs to
us.

Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 6bf387b..815f683 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -52,7 +52,7 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);

-MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
+MODULE_AUTHOR("Qualcomm Corporation, <nic-devel@qualcomm.com>");
 MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");

--
1.7.7
