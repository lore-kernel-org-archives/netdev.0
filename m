From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: How to deal with a PHY configuration related to the board?
Date: Tue, 14 Feb 2012 10:26:06 +0100
Message-ID: <20120214092606.GE4723@ldesroches-Latitude-E6320>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ferre, Nicolas" <nicolas.ferre@atmel.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:47280 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423Ab2BNJ0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 04:26:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am using a Micrel KSZ9021RN PHY and I would like to configure some registers
as 'RGMII Clock and Control Pad Skew' and 'RGMII RX Data Pad Skew'.
So the values of these registers are board dependant and I wondering what is
the proper way to set them.
It seems there is no platform data usable for this case. Having a quick look
to other PHYs, the situation seems the same.

Can you give me some clues about how to do this? Did I miss anything which
allow to do this?

Thanks

Regards

Ludovic
