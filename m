From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool maintenance
Date: Mon, 15 Nov 2010 14:46:27 +0000
Message-ID: <1289832387.2586.10.camel@bwh-desktop>
References: <4CDE502D.6000506@garzik.org>
	 <1289658614.2816.105.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Peter Martuccelli <peterm@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16156 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab0KOOqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 09:46:30 -0500
In-Reply-To: <1289658614.2816.105.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-11-13 at 14:30 +0000, Ben Hutchings wrote:
> On Sat, 2010-11-13 at 03:45 -0500, Jeff Garzik wrote:
> > So, a recent emergency surgery has really set me back, work-wise. 
> > ethtool [the userspace utility] 2.6.36 is still not out, and personally 
> > it remains a third or fourth priority.
> > 
> > While it's likely that I could get back to ethtool's patch queue next 
> > week, it continues to be low man on the totem pole.  Seems only fair to 
> > see if anyone else is interested in maintaining it.
> > 
> > I emailed Ben Hutchings privately about this, but haven't heard back, so 
> > I thought I'd go ahead and email the list.
> > 
> > Anyone interested?
> 
> I am interested, but will need to clear it with my boss before making
> such a commitment.

OK, this is fine.  Are there any patches waiting other than mine and
these?

http://patchwork.ozlabs.org/patch/67662/
http://patchwork.ozlabs.org/patch/68237/
http://patchwork.ozlabs.org/patch/69155/

I'll need to sort out my kernel.org account before I can publish a git
tree.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

