From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: phy: neaten phy_print_status
Date: Thu, 23 Jan 2014 12:17:45 -0800
Message-ID: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <joe@perches.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:41025 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbaAWUSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:18:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Joe,

This patchset neatens phy_print_status based on earlier feedback from Joe.

Thanks!

Florian Fainelli (4):
  net: phy: use network device in phy_print_status
  net: phy: update phy_print_status to show pause settings
  net: phy: display human readable PHY speed settings
  net: phy: remove unneeded parenthesis

 drivers/net/phy/phy.c | 36 ++++++++++++++++++++++++++++--------
 1 file changed, 28 insertions(+), 8 deletions(-)

-- 
1.8.3.2
