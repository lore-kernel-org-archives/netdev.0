From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-10-10
Date: Wed, 10 Oct 2012 22:39:35 +0200
Message-ID: <1349901576-30774-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, socketcan@hartkopp.net,
	netdev@vger.kernel.org, dhowells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56306 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252Ab2JJUjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 16:39:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this pull request for net, i.e. the v3.7 release cycle, contains the patch by
David Howells to move the UAPI related headers for the CAN subsystem.

regards, Marc

--

The following changes since commit 85457685e0e314f6902caaef976b3fd8ef4f51b4:

  Merge tag 'master-2012-10-08' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2012-10-10 11:59:54 -0400)

are available in the git repository at:


  git://gitorious.org/linux-can/linux-can.git uapi-for-3.7

for you to fetch changes up to 922cd657c95fe3e4214d68a958e98288b7a55bba:

  UAPI: (Scripted) Disintegrate include/linux/can (2012-10-10 22:24:21 +0200)

----------------------------------------------------------------
David Howells (1):
      UAPI: (Scripted) Disintegrate include/linux/can

 include/linux/can/Kbuild               |    5 -----
 include/uapi/linux/can/Kbuild          |    5 +++++
 include/{ => uapi}/linux/can/bcm.h     |    0
 include/{ => uapi}/linux/can/error.h   |    0
 include/{ => uapi}/linux/can/gw.h      |    0
 include/{ => uapi}/linux/can/netlink.h |    0
 include/{ => uapi}/linux/can/raw.h     |    0
 7 files changed, 5 insertions(+), 5 deletions(-)
 rename include/{ => uapi}/linux/can/bcm.h (100%)
 rename include/{ => uapi}/linux/can/error.h (100%)
 rename include/{ => uapi}/linux/can/gw.h (100%)
 rename include/{ => uapi}/linux/can/netlink.h (100%)
 rename include/{ => uapi}/linux/can/raw.h (100%)
