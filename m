From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/5] constify ethtool_ops structures
Date: Thu,  1 Sep 2016 00:21:18 +0200
Message-ID: <1472682083-5219-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mediatek@lists.infradead.org,
 =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
 linux-arm-kernel@lists.infradead.org
To: linux-usb@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Constify ethtool_ops structures.

---

 drivers/net/ethernet/mediatek/mtk_eth_soc.c       |    2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c       |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 drivers/net/usb/r8152.c                           |    2 +-
 drivers/staging/netlogic/xlr_net.c                |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)
