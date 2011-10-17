From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 0/2] MAINTAINERS: can: the mailinglist moved to vger.kernel.org
Date: Mon, 17 Oct 2011 21:31:58 +0200
Message-ID: <1318879920-25280-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40029 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab1JQTcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 15:32:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

the BerliOS project will close with the end of the year, so we moved our
mailinglist to vger.kernel.org, it's now linux-can@vger.kernel.org.

This patch series change the mailinglist in MAINTAINERS and remove all other
references from the source tree. As David pointed out, automated tool will
use MAINTAINERS to gather this information.

cheers, Marc

The following changes since commit fd38f734cb8200529e281338514945fcbff2364b:

  igbvf: convert to ndo_fix_features (2011-10-16 13:18:47 -0700)

are available in the git repository at:
  git.pengutronix.de:/git/mkl/linux-2.6.git can/mailinglist-for-net-next

Marc Kleine-Budde (2):
      MAINTAINERS: can: the mailinglist moved to vger.kernel.org
      can: remove references to berlios mailinglist

 MAINTAINERS                       |    4 ++--
 drivers/net/can/at91_can.c        |    2 --
 drivers/net/can/sja1000/sja1000.c |    2 --
 drivers/net/can/sja1000/sja1000.h |    2 --
 drivers/net/can/slcan.c           |    2 --
 drivers/net/can/vcan.c            |    2 --
 include/linux/can.h               |    2 --
 include/linux/can/bcm.h           |    2 --
 include/linux/can/core.h          |    2 --
 include/linux/can/dev.h           |    1 -
 include/linux/can/error.h         |    2 --
 include/linux/can/gw.h            |    2 --
 include/linux/can/netlink.h       |    2 --
 include/linux/can/raw.h           |    2 --
 net/can/af_can.c                  |    2 --
 net/can/af_can.h                  |    2 --
 net/can/bcm.c                     |    2 --
 net/can/gw.c                      |    2 --
 net/can/proc.c                    |    2 --
 net/can/raw.c                     |    2 --
 20 files changed, 2 insertions(+), 39 deletions(-)
