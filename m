From: <Woojung.Huh@microchip.com>
Subject: [PATCH 0/2 net] lan78xx: patch series
Date: Mon, 25 Apr 2016 22:22:31 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D408987E7@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:55451 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750843AbcDYWWe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 18:22:34 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Woojung Huh (2):
 lan78xx: fix statistics counter error
 lan78xx: workaround of forced 100 Full/Half duplex mode error

 drivers/net/usb/lan78xx.c | 44 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 38 insertions(+), 6 deletions(-)

-- 
2.8.1
