From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/2] replace IS_ERR_OR_NULL by IS_ERR
Date: Wed, 16 Nov 2016 11:43:32 +0100
Message-ID: <1479293014-18811-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace IS_ERR_OR_NULL by IS_ERR on knav_queue_open calls.

---

 drivers/net/ethernet/ti/netcp_core.c |    6 +++---
 drivers/soc/ti/knav_qmss_queue.c     |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)
