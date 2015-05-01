From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-05-01
Date: Fri,  1 May 2015 10:28:57 +0200
Message-ID: <1430468938-28173-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of a single patch for net/master.

The patch is contributed by Jeppe Ledet-Pedersen, it fixes the extended frame
handling in the xilinx driver.

regards,
Marc

---

The following changes since commit e813bb2b955d9f72c94be7d592746b49929a499b:

  net: fec: Fix RGMII-ID mode (2015-04-30 16:48:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.1-20150501

for you to fetch changes up to 5793affe8c723ece8114b898ab9003c7d97f86d1:

  net: can: xilinx_can: fix extended frame handling (2015-05-01 10:11:46 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.1-20150501

----------------------------------------------------------------
Jeppe Ledet-Pedersen (1):
      net: can: xilinx_can: fix extended frame handling

 drivers/net/can/xilinx_can.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)


