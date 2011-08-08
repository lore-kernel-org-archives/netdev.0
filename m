From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/2] bnx2x: Logging message cleanups
Date: Mon,  8 Aug 2011 08:53:03 -0700
Message-ID: <cover.1312818707.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  bnx2x: Remove local defines for %pM and mac address
  bnx2x: Coalesce pr_cont uses and fix DP typos

 drivers/net/bnx2x/bnx2x.h      |    4 -
 drivers/net/bnx2x/bnx2x_cmn.c  |   42 ++++++-----
 drivers/net/bnx2x/bnx2x_cmn.h  |    4 +-
 drivers/net/bnx2x/bnx2x_dcb.c  |    2 +-
 drivers/net/bnx2x/bnx2x_link.c |  155 +++++++++++++++++++++-------------------
 drivers/net/bnx2x/bnx2x_main.c |   47 ++++++-------
 drivers/net/bnx2x/bnx2x_sp.c   |   64 ++++++++---------
 7 files changed, 158 insertions(+), 160 deletions(-)

-- 
1.7.6.405.gc1be0
