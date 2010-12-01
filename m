From: David Miller <davem@davemloft.net>
Subject: Re: skge.c patch to limit DMA for ASUS A8N-SLI Premium board
Date: Wed, 01 Dec 2010 11:00:48 -0800 (PST)
Message-ID: <20101201.110048.260084123.davem@davemloft.net>
References: <4CEEFA11.6040205@fremnet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kernel.org.alias@fremnet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754052Ab0LATAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:00:21 -0500
In-Reply-To: <4CEEFA11.6040205@fremnet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Wynter <kernel.org.alias@fremnet.net>
Date: Fri, 26 Nov 2010 10:06:41 +1000

> Hi
> 
> I would like to contribute a patch to add ASUS A8N-SLI Premium to the
> list of boards that require the quirk to limit DMA to 32bit in the
> skge.c module.
> 
> It took 2 hours of fiddling with my machine last night to get the
> network card working - the lights were on but no-one was at home.
> 
> I never would have found it if not for the original bug listed on
> redhat for the Gigabyte motherboard.

Please resubmit this with a proper "Signed-off-by: " tag as per
Documentation/SubmittingPatches

Thank you.
