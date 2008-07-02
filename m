From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Add support for rx flow hash configuration in a
 network device
Date: Wed, 02 Jul 2008 03:50:22 -0700 (PDT)
Message-ID: <20080702.035022.204721470.davem@davemloft.net>
References: <48658078.8030707@Sun.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, Matheos.Worku@Sun.COM,
	Michael.Speer@Sun.COM, gkernel-commit@lists.sourceforge.net
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754139AbYGBKuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 06:50:22 -0400
In-Reply-To: <48658078.8030707@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santwona Behera <Santwona.Behera@Sun.COM>
Date: Fri, 27 Jun 2008 17:06:16 -0700

> This feature has 3 related patches:
> 
> 1. An ethtool application patch.
> 2. A kernel patch for the ethtool interface.
> 3. A kernel patch for the niu driver that implements the ethtool config 
> ioctl functions. NOTE: The niu driver already has rx flow hashing 
> implemented. With these 3 patches, this feature is now configurable 
> using ethtool.

Thanks for doing this work Santwona.

I've applied patch 2 and 3 to my net-next-2.6 kernel tree.

I spoke with Jeff Garzik, and he will add your first patch
to the ethtool tree when he gets a chance.

Thanks again!
