From: <Woojung.Huh@microchip.com>
Subject: [PATCH 0/2] lan78xx: patch series
Date: Tue, 15 Mar 2016 22:52:10 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404C9059@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:48744 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751131AbcCOWwM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 18:52:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Woojung Huh (2):
  lan78xx: handle statistics counter rollover
  lan78xx: add ndo_get_stats64

 drivers/net/usb/lan78xx.c | 301 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 288 insertions(+), 13 deletions(-)

-- 
2.7.0
