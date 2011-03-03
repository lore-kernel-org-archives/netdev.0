From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bonding...
Date: Thu, 3 Mar 2011 06:45:39 -0500
Message-ID: <20110303114539.GB5146@hmsreliant.think-freely.org>
References: <20110302.214910.112578818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52852 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab1CCLpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 06:45:50 -0500
Content-Disposition: inline
In-Reply-To: <20110302.214910.112578818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 09:49:10PM -0800, David Miller wrote:
> 
> Hey, if someone could step up and help with bonding maintainence
> in some tangible way, I'd really appreciate it.
> 
> Currently the situation is that many people work on bonding patches,
> and whilst I do try and wait for some ACKs to arrive, I am the person
> who has to sort out when changes are ready, decide to apply them, and
> poke for review when things fall through the cracks.
> 
> Sometimes patches go for weeks without ACKs, and in that situation
> I have to either try to understand the changes myself, or wait
> potentially forever for someone with bonding knowledge to take a
> good look at the patch and properly review it.
> 
> It was nearly 2 weeks before Oleg V. Ukhno's 802.3ad round-robin patch
> got looked at by anyone with bonding knowledge.  And it only happened
> because I got tired of seeing his poor patch rot in patchwork
> and had to explicitly asked for review the other day.
> 
> This is unacceptable, people are submitting multiple bonding patches
> every single day now.  It needs a clueful bonding person looking at
> these submissions on a constant basis.
> 
> This is a serious problem and is backlogging the netdev patch queue.
> 
> So if someone would become an active bonding patch-accumulator, and
> send me sets of patches that are ready to apply, I would really
> appreciate it.
> 
> Thanks.
I nominate gospo.  If he doesn't want to, I can do it
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
