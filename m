From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH 0/2] net: ethernet: bgmac: bug fixes
Date: Wed,  1 Feb 2017 17:39:10 -0500
Message-ID: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bug fixes for bgmac driver

Hari Vyas (1):
  net: ethernet: bgmac: mac address change bug

Zac Schroff (1):
  net: ethernet: bgmac: init sequence bug

 drivers/net/ethernet/broadcom/bgmac-platform.c | 10 +++++++---
 drivers/net/ethernet/broadcom/bgmac.c          |  6 +++++-
 include/linux/bcma/bcma_regs.h                 |  1 +
 3 files changed, 13 insertions(+), 4 deletions(-)

-- 
2.7.4
