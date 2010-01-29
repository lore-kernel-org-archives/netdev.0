From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH 00/13] drivers/net/tulip: Cleanups
Date: Thu, 28 Jan 2010 22:59:16 -0800
Message-ID: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1577 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753867Ab0A2G7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch errors ignored

Joe Perches (13):
  tulip_core: Use dev_<level> and pr_<level>
  tulip/21142.c: Use dev_<level> and pr_<level>
  tulip/de2104x.c: Use dev_<level> and pr_<level>
  tulip/dmfe.c: Use dev_<level> and pr_<level>
  tulip/eeprom.c: Use dev_<level> and pr_<level>
  tulip/interrupt.c: Use dev_<level> and pr_<level>
  tulip/media.c: Use dev_<level> and pr_<level>
  tulip/pnic.c: Use dev_<level> and pr_<level>
  tulip/pnic2.c: Use dev_<level> and pr_<level>
  tulip/timer.c: Use dev_<level> and pr_<level>
  tulip/uli526x.c: Use dev_<level> and pr_<level>
  tulip/winbond-840.c: Use dev_<level> and pr_<level>
  tulip/xircom_cb.c: Use dev_<level> and pr_<level>

 drivers/net/tulip/21142.c       |   76 +++++++++--------
 drivers/net/tulip/de2104x.c     |  138 +++++++++++++++---------------
 drivers/net/tulip/dmfe.c        |   67 +++++++--------
 drivers/net/tulip/eeprom.c      |   47 +++++-----
 drivers/net/tulip/interrupt.c   |  100 ++++++++++++----------
 drivers/net/tulip/media.c       |   74 ++++++++--------
 drivers/net/tulip/pnic.c        |   33 ++++----
 drivers/net/tulip/pnic2.c       |   59 +++++++-------
 drivers/net/tulip/timer.c       |   52 ++++++------
 drivers/net/tulip/tulip_core.c  |  162 ++++++++++++++++++------------------
 drivers/net/tulip/uli526x.c     |   46 ++++++----
 drivers/net/tulip/winbond-840.c |  177 ++++++++++++++++++++-------------------
 drivers/net/tulip/xircom_cb.c   |   44 ++++++----
 13 files changed, 547 insertions(+), 528 deletions(-)

