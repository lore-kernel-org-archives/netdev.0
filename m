From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Tue, 30 Sep 2008 04:57:54 +0200
Message-ID: <20080930025754.GC3251@xi.wantstofly.org>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org> <20080929053931.GB21663@2ka.mipt.ru> <20080929094650.GA26097@xi.wantstofly.org> <36D9DB17C6DE9E40B059440DB8D95F52064B198F@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Ram.Natarajan@Emulex.Com, Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:51402 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbYI3C54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 22:57:56 -0400
Content-Disposition: inline
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52064B198F@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 01:21:05PM -0700, Brandeburg, Jesse wrote:

> > Could you (or anyone else) try this patch on one of your boxes and
> > see what kind of effect it has on performance?
> 
> Lennert, we're very interested in this kind of work, and I'll see what
> we can come up with by porting ixgbe or igb to use the patch. 

Cool, thanks.  I'd be very interested what kind of difference it
makes (if any) on larger systems than the ones I've tried it on.


> Bad news is it may be as far away as a couple of weeks, because of
> this e1000e corrupt NVM thing I'm working on.

I really hope you'll figure that one out soon..
