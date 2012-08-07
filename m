From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-08-07
Date: Tue,  7 Aug 2012 12:04:17 +0200
Message-ID: <1344333858-11944-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here's a fix intended for the v3.6 release cycle. Oliver noticed and
fixed that the flags definition for the new canfd_frame contains
redundant and confusing information.

regards,
Marc

--

The following changes since commit 5d299f3d3c8a2fbc732b1bf03af36333ccec3130:

  net: ipv6: fix TCP early demux (2012-08-06 13:33:21 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.6

for you to fetch changes up to 035534ed3377d9def2c17717899fd64a111a785b:

  canfd: remove redundant CAN FD flag (2012-08-07 10:10:57 +0200)

----------------------------------------------------------------
Oliver Hartkopp (1):
      canfd: remove redundant CAN FD flag

 include/linux/can.h |   25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

