From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-07-16
Date: Thu, 16 Jul 2015 10:33:53 +0200
Message-ID: <1437035635-18635-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of 2 patches by Stefan Agner. He fixes the resume
operation in the mcp251x driver.

regards,
Marc

---

The following changes since commit 15afb10df4a3f1bd781373ffd968e70cc4b21a42:

  Merge branch 'for-upstream' of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth (2015-07-15 21:59:23 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.2-20150716

for you to fetch changes up to 69da3f2ac528642acbd06ed14564ac1b9a918394:

  can: mcp251x: get regulators optionally (2015-07-16 09:04:22 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.2-20150716

----------------------------------------------------------------
Stefan Agner (2):
      can: mcp251x: fix resume when device is down
      can: mcp251x: get regulators optionally

 drivers/net/can/spi/mcp251x.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

