From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/3] bonding: More ether_addr_copy and neatenings.
Date: Tue, 18 Feb 2014 09:42:44 -0800
Message-ID: <cover.1392745013.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (3):
  bonding: More use of ether_addr_copy
  bonding: Remove unnecessary else
  bonding: Invert test

 drivers/net/bonding/bond_3ad.c  | 21 ++++++++++-----------
 drivers/net/bonding/bond_alb.c  | 17 ++++++++---------
 drivers/net/bonding/bond_main.c |  6 +++---
 3 files changed, 21 insertions(+), 23 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
