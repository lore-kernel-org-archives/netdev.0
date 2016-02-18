From: <Woojung.Huh@microchip.com>
Subject: [PATCH V2 net-next 0/3] lan78xx: driver update
Date: Thu, 18 Feb 2016 22:40:03 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404B37A7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:27668 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756908AbcBRWkE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 17:40:04 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add new ethtool functions of set_pauseparam  & get_pauseparam
and MAINTAINERS entry.

Woojung Huh (3):
  lan78xx: replace devid to chipid & chiprev
  lan78xx: add ethtool set & get pause functions
  MAINTAINERS: Add LAN78XX entry

 MAINTAINERS               |   7 ++++
 drivers/net/usb/lan78xx.c | 104 ++++++++++++++++++++++++++++++++++++++++------
 drivers/net/usb/lan78xx.h |   1 +
 3 files changed, 100 insertions(+), 12 deletions(-)

-- 
2.7.0
