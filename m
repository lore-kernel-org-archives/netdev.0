From: <Nisar.Sayed@microchip.com>
Subject: [PATCH net 0/2] lan78xx: Fixes to lan78xx driver
Date: Tue, 1 Aug 2017 10:23:52 +0000
Message-ID: <CE371C1263339941885964188A0225FA322BC3@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <UNGLinuxDriver@microchip.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:30068 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdHAKYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:24:40 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nisar Sayed <Nisar.Sayed@microchip.com>

This series of patches are for lan78xx driver.

These patches fixes potential issues associated with lan78xx driver

Nisar Sayed (2):
  USB fast connect/disconnect crash fix
  Fix to handle hard_header_len update

 drivers/net/usb/lan78xx.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

-- 
1.9.1
