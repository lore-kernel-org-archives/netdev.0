From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/3 net-next] dsa: bugfixing and typos after Device Tree bindings
Date: Mon, 25 Mar 2013 16:03:37 +0100
Message-ID: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43599 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002Ab3CYPDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 11:03:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Please find here 3 minor bugfixes related to my recent device tree bindings
additions to DSA. Thanks!

Florian Fainelli (3):
  dsa: fix device tree binding documentation typo on #address-cells
  dsa: factor freeing of dsa_platform_data
  dsa: fix freeing of sparse port allocation

 Documentation/devicetree/bindings/net/dsa/dsa.txt |    2 +-
 net/dsa/dsa.c                                     |   40 ++++++++++-----------
 2 files changed, 21 insertions(+), 21 deletions(-)

-- 
1.7.10.4
