From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 0/3] smsc95xx: patch serises
Date: Fri, 2 Sep 2016 20:34:17 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40910090@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <steve.glendinning@shawell.net>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:34335 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751974AbcIBUeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:34:19 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Woojung Huh (3):
  Smsc95xx: Add maintainer
  smsc95xx: Add register define
  smsc95xx: Add mdix control via ethtool

 MAINTAINERS                |   1 +
 drivers/net/usb/smsc95xx.c | 109 +++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/usb/smsc95xx.h |   8 ++++
 3 files changed, 115 insertions(+), 3 deletions(-)

-- 
2.7.4
