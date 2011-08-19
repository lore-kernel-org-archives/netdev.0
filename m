From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH/RFC v3 0/75] enable SKB paged fragment lifetime
 visibility
Date: Fri, 19 Aug 2011 15:30:15 +0100
Message-ID: <1313764215.5010.377.camel@zakaz.uk.xensource.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
	 <20110819.062958.1560313540665582388.davem@davemloft.net>
	 <20110819.063410.475175569086272526.davem@davemloft.net>
	 <20110819.070451.1651299907098952592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-nfs@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:50649 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab1HSOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 10:30:17 -0400
In-Reply-To: <20110819.070451.1651299907098952592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 07:04 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 19 Aug 2011 06:34:10 -0700 (PDT)
> 
> > From: David Miller <davem@davemloft.net>
> > Date: Fri, 19 Aug 2011 06:29:58 -0700 (PDT)
> > 
> >> From: Ian Campbell <Ian.Campbell@citrix.com>
> >> Date: Fri, 19 Aug 2011 14:26:33 +0100
> >> 
> >>> This is v3 of my series to enable visibility into SKB paged fragment's
> >> 
> >> Please tone down the patch count :-/  I'm not going to review anything more
> >> than ~20 or so patches at a time from any one person.
> > 
> > Also none of your patches will even apply to net-next GIT since nearly
> > all the ethernet drivers have been moved under drivers/net/ethernet
> 
> Ian, please acknowledge my grievances here.  I see you replying to other
> people, but not to me and I'm the one who has to process all of this
> stuff eventually.

Sorry, I thought I had replied to you first, did it go missing?

> If you want this series to be taken seriously:
> 
> 1) Make your patches against net-next GIT, none of your driver patches will
>    apply because they have all been moved around to different locations
>    under drivers/net

> 2) Submit this in a _SANE_ way.  This means, get the first patch that adds
>    the new interfaces approved and merged.  Then slowly and carefuly submit
>    small, reasonably sized, sets of patches that convert the drivers over.

That all makes sense, I'll do it that way.

> Otherwise there is no way I'm even looking at this stuff, let alone actually
> apply it.

> Realize that every time you patch bomb rediculiously like this I have
> to click and classify every single patch in your bomb at
> http://patchwork.ozlabs.org/project/netdev/list/

Ah, right, I hadn't considered the patchwork thing, I'm very sorry about
that!

Ian.


