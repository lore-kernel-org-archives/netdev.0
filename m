From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/9] net: phy: fix checkpatch errors
Date: Tue, 17 Dec 2013 21:38:04 -0800
Message-ID: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:52338 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3LRFiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:22 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so7738584oag.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This patchset fixes trivial checkpatch errors, no functional change
introduced.

Thanks!

Florian Fainelli (9):
  net: phy: cicada: fix checkpath errors
  net: phy: davicom: fix checkpath errors
  net: phy: dp83640: fix checkpath error
  net: phy: icplus: fix checkpath error
  net: phy: lxt: fix checkpath errors
  net: phy: mdio_bus: fix checkpath error
  net: phy: micrel: fix checkpath errors
  net: phy: fix checkpatch errors
  net: phy: spi_ks8995: fix checkpatch errors

 drivers/net/phy/cicada.c     |   4 +-
 drivers/net/phy/davicom.c    |   2 +-
 drivers/net/phy/dp83640.c    |   4 +-
 drivers/net/phy/icplus.c     |   2 +-
 drivers/net/phy/lxt.c        |   4 +-
 drivers/net/phy/mdio_bus.c   |   4 +-
 drivers/net/phy/micrel.c     |   4 +-
 drivers/net/phy/phy.c        | 264 +++++++++++++++++++++----------------------
 drivers/net/phy/phy_device.c |  14 +--
 drivers/net/phy/spi_ks8995.c |   4 +-
 10 files changed, 153 insertions(+), 153 deletions(-)

-- 
1.8.3.2
