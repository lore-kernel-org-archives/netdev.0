From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-05-28
Date: Wed, 28 May 2014 10:04:42 +0200
Message-ID: <1401264283-9353-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a pull request for v3.15, hope it's not too late.

Oliver Hartkopp fixed a bug in the CAN led trigger device renaming code.

regards,
Marc

---

The following changes since commit 8646224cdb945eca4293e2131e5be47930ce3e80:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2014-05-24 14:06:19 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.15-20140528

for you to fetch changes up to 45fb4f8d81578e0a17c45c4593a3305afbf7a48b:

  can: only rename enabled led triggers when changing the netdev name (2014-05-27 15:05:41 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.15-20140528

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: only rename enabled led triggers when changing the netdev name

 drivers/net/can/led.c | 3 +++
 1 file changed, 3 insertions(+)


