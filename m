From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-12-14
Date: Fri, 14 Dec 2012 22:33:43 +0100
Message-ID: <1355520824-23175-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, sfr@canb.auug.org.au,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a patch for net for the v3.8 release cycle. Randy Dunlap found a
compilation problem of the sja1000_of_platform driver on X86_32. A patch by me
fixes the problem.

regards, Marc

---

The following changes since commit 17bc14b767cf0692420c43dbe5310ae98a5a7836:

  Revert "sched: Update_cfs_shares at period edge" (2012-12-14 07:20:43 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.8

for you to fetch changes up to 27d5155f676598e461d9038eadf77bfebce48f30:

  can: sja1000: fix compilation on x86 (2012-12-14 22:07:10 +0100)

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: sja1000: fix compilation on x86

 drivers/net/can/sja1000/sja1000_of_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


