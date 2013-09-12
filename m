From: Rayagond K <rayagond@vayavyalabs.com>
Subject: XGMII support
Date: Thu, 12 Sep 2013 10:00:03 +0530
Message-ID: <CAJ3bTp5kc-4eqQObCJ7xyCBTrBGp3yGLRGQZZMXdhTvsYahLFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:44045 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012Ab3ILEaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 00:30:04 -0400
Received: by mail-wg0-f53.google.com with SMTP id x12so6281574wgg.8
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 21:30:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I was going through include/linux/phy.h file to check what all phy
interface Linux supports. The enum "phy_interface_t" has entry for
MII, GMII, TBI, SGMII, RMII etc but I didn't find entry for XGMII
interface.  So my questions are following,

1. How to support XGMII using phylib ?
2. What are PHY_INTERFACE_MODE_RGMII_ID, PHY_INTERFACE_MODE_RGMII_RXID
and PHY_INTERFACE_MODE_RGMII_TXID ?

wwr
Rayagond
