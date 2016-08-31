From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/6] constify ethtool_ops structures
Date: Wed, 31 Aug 2016 09:30:42 +0200
Message-ID: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: devel@driverdev.osuosl.org
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

 drivers/net/ethernet/agere/et131x.c              |    2 +-
 drivers/net/ethernet/broadcom/bcmsysport.c       |    2 +-
 drivers/net/ethernet/broadcom/genet/bcmgenet.c   |    2 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c       |    2 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c      |    2 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c    |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c |    2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c      |    2 +-
 drivers/staging/slicoss/slicoss.c                |    4 ++--
 9 files changed, 10 insertions(+), 10 deletions(-)
