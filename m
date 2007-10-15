From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support
	to NEW EMAC.
Date: Tue, 16 Oct 2007 07:05:23 +1000
Message-ID: <1192482323.11795.38.camel@pasglop>
References: <20071015175717.GA4602@ru.mvista.com>
	 <4713B10B.5000607@garzik.org>
	 <20071015134813.6aacdcca@weaponx.rchland.ibm.com>
	 <4713B726.6080404@garzik.org>
	 <20071015135959.5b603d7d@weaponx.rchland.ibm.com>
	 <4713B9C1.5010001@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40882 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbXJOVLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:11:37 -0400
In-Reply-To: <4713B9C1.5010001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-10-15 at 15:04 -0400, Jeff Garzik wrote:
> I would ideally like a single active patch generator (even if they
> are 
> merely reviewed others work sometimes).
> 
> Outside of that, I'm hoping you and the other people listed making 
> changes will self-organize without my help :)

Josh, do you want to be the central point / maintainer for it or do you
want me to do it ? There's a lot of code from me in there and I did this
fork in the first place so I have a pretty good idea of what's going on
in this driver and what still needs to be done :-)

Cheers,
Ben.



