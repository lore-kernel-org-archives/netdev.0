From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 13:12:56 -0700
Message-ID: <1383163976.4857.61.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.220253.1263087684709722001.davem@davemloft.net>
	 <20131030020543.GA1925@gondor.apana.org.au>
	 <1383161957.1601.27.camel@bwh-desktop.uk.level5networks.com>
	 <1383162786.4857.53.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383163525.1601.28.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:49562 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab3J3UM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:12:58 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so1476094pab.14
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 13:12:57 -0700 (PDT)
In-Reply-To: <1383163525.1601.28.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 20:05 +0000, Ben Hutchings wrote:
> On Wed, 2013-10-30 at 12:53 -0700, Eric Dumazet wrote:
> > On Wed, 2013-10-30 at 19:39 +0000, Ben Hutchings wrote:
> > 
> > > I think the change to enable mega-GRO packets should be reverted and
> > > that change should go to stable so that the performance regression for
> > > forwarding is also fixed.
> > 
> > What are you talking about ?
> > 
> > The change is in net-next only.
> > 
> > It seems a lot of people talk, but few people try to help.
> 
> Sorry :-/
> 

Sorry, my last sentence was harsh.

I meant that patch was sent October 8th, and bug discovered only 2 days
ago. I sent two patches to fix the bug, and will send other patches as
well, so asking for a revert is I think premature, give me some time
to make forward progress ;)

Thanks !
