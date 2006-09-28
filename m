From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/1] atl1: New driver, Attansic L1 Gigabit Ethernet
Date: Thu, 28 Sep 2006 22:01:54 +0200
Message-ID: <20060928200154.GA28658@electric-eye.fr.zoreil.com>
References: <20060927132119.GB11922@osprey.hogchain.net> <20060928065912.GA6647@electric-eye.fr.zoreil.com> <20060928130304.GA4775@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:11415 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751958AbWI1UCB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 16:02:01 -0400
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20060928130304.GA4775@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> :
[...]
> You will note that it's in a directory called "obsolete."  That's
> because it is undergoing significant rework based on shemminger's
> comments and other considerations.
> 
> A new version will be posted in the upcoming days.

Nice.

Whishlist:
- __iomem annotations;
- less MixedCase;
- less typedef;
- more vowels or less drv (drvrrd, drvtrd, drvtxf, grmbl);
- DMA_xxBIT_MASK may help;
- request_irq(... IRQF_SHARED, ...).

-- 
Ueimor 
