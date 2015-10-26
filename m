From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] mvneta ethtool statistics
Date: Sun, 25 Oct 2015 18:21:37 -0700 (PDT)
Message-ID: <20151025.182137.2066098234931624844.davem@davemloft.net>
References: <20151022173711.GA23501@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	mw@semihalf.com, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55633 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbbJZBFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 21:05:01 -0400
In-Reply-To: <20151022173711.GA23501@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Thu, 22 Oct 2015 18:37:11 +0100

> Sorry for v3 - I forgot to update the commit message on patch 1 as
> requested by Marcin.
> 
> This short series adds ethtool statistics reporting to mvneta.  Having
> discussed with Andrew on IRC, we decided I'd pick up his patch into my
> series.
> 
> My change for patch 1 compared to the previous RFC splits out the
> reading of the statistics from the hardware into a separate function,
> in order to facilitate work going on elsewhere to arrange for the
> statistics to be preserved across a suspend/resume cycle.

Series applied to net-next, thanks Russell.
