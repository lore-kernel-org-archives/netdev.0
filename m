From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH kernel 2.6.32-rc5] [RESEND] netdev: usb: dm9601.c can
 drive a device not supported yet, add support for it
Date: Thu, 29 Oct 2009 01:32:23 -0700 (PDT)
Message-ID: <20091029.013223.30308741.davem@davemloft.net>
References: <200910222025.50405.jkrzyszt@tis.icnet.pl>
	<87my3jnts0.fsf@macbook.be.48ers.dk>
	<200910281634.23635.jkrzyszt@tis.icnet.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, netdev@vger.kernel.org
To: jkrzyszt@tis.icnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753299AbZJ2Ib7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:31:59 -0400
In-Reply-To: <200910281634.23635.jkrzyszt@tis.icnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Date: Wed, 28 Oct 2009 16:34:21 +0100

> I found that the current version of drivers/net/usb/dm9601.c can be used to
> successfully drive a low-power, low-cost network adapter with USB ID
> 0a46:9000, based on a DM9000E chipset. As no device with this ID is yet
> present in the kernel, I have created a patch that adds support for the device
> to the dm9601 driver.
> 
> Created and tested against linux-2.6.32-rc5.
> 
> Signed-off-by: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

Applied to net-2.6, thanks.
