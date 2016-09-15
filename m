From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/3] constify net_device_ops structures
Date: Thu, 15 Sep 2016 22:23:23 +0200
Message-ID: <1473971006-2074-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Constify net_device_ops structures.

---

 drivers/net/ethernet/hisilicon/hip04_eth.c  |    2 +-
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |    2 +-
 net/l2tp/l2tp_eth.c                         |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)
