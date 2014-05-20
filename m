From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 0/2] net: fec: Add fec sleep pinctrl for pin PM state
Date: Tue, 20 May 2014 14:50:43 +0800
Message-ID: <1400568645-10214-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>, <B38611@freescale.com>,
	<b20596@freescale.com>
To: <davem@davemloft.net>, <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0189.outbound.protection.outlook.com ([207.46.163.189]:20382
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751630AbaETIJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 04:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The two patches is to add fec sleep pinctrl for pin PM state in imx6sl
evk platform.

Fugang Duan (2):
  ARM: dts: imx6sl: add fec sleep pinctrl for pin PM state
  net: fec: use pinctrl PM helpers

 arch/arm/boot/dts/imx6sl-evk.dts          |   16 +++++++++++++++-
 drivers/net/ethernet/freescale/fec_main.c |   10 ++++++++++
 2 files changed, 25 insertions(+), 1 deletions(-)

-- 
1.7.8
