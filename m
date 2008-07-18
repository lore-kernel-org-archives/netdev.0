From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Fri, 18 Jul 2008 05:12:10 +0000
Message-ID: <20080718051210.GA2650@ff.dom.local>
References: <20080714212620.GA8503@orion.carnet.hr> <20080714214851.GB4849@ami.dom.local> <20080717213058.GA28252@orion.carnet.hr> <20080717.144407.37848445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joy@entuzijast.net, kaber@trash.net, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:28140 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbYGRFHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 01:07:12 -0400
Received: by yw-out-2324.google.com with SMTP id 9so54455ywe.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 22:07:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080717.144407.37848445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 02:44:07PM -0700, David Miller wrote:
> From: Josip Rodin <joy@entuzijast.net>
> Date: Thu, 17 Jul 2008 23:30:58 +0200
> 
> > It looks like the patch fixed my issues - no relevant printk's appeared
> > since I've applied it, so apparently there is no more cloned skb splitting
> > or corrupted data getting to bnx2.
> > 
> > I used the latest variant, from Jarek's mail
> > <20080714212223.GA4849@ami.dom.local>, on the 2.6.25.6 kernel.
> > 
> > Thanks all!
> > 
> > (Now if only someone could make sure this propagates into the stable kernel
> > branches, since those were pretty nasty crashes...)
> 
> We will make sure the fix propagates in some form, thanks for testing.

What an ... attempt!

Congratulations to everybody here,
Jarek P.
