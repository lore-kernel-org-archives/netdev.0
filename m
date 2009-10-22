From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] DRIVERS: NET: USB: DM9601 driver can drive a device not supported yet, add support for it
Date: Thu, 22 Oct 2009 20:54:55 +0200
Message-ID: <87my3jnts0.fsf@macbook.be.48ers.dk>
References: <200910222025.50405.jkrzyszt@tis.icnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:11482 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756662AbZJVSyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 14:54:55 -0400
Received: by ey-out-2122.google.com with SMTP id 9so1761644eyd.19
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 11:54:59 -0700 (PDT)
In-Reply-To: <200910222025.50405.jkrzyszt@tis.icnet.pl> (Janusz Krzysztofik's message of "Thu\, 22 Oct 2009 20\:25\:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Janusz" == Janusz Krzysztofik <jkrzyszt@tis.icnet.pl> writes:

 Janusz> Hi,
 Janusz> I found that the current version of drivers/net/usb/dm9601.c can be used to
 Janusz> successfully drive a low-power, low-cost network adapter with USB ID
 Janusz> 0a46:9000, based on a DM9000E chipset. As no device with this ID is yet
 Janusz> present in the kernel, I have created a patch that adds support for the device
 Janusz> to the dm9601 driver.

 Janusz> Created and tested against linux-2.6.32-rc5.

 Janusz> Signed-off-by: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>

Thanks.

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
