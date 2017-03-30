From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Thu, 30 Mar 2017 11:46:18 +1100
Message-ID: <1490834778.3177.197.camel@kernel.crashing.org>
References: <1490762446.3177.164.camel@kernel.crashing.org>
         <20170328.215744.794906222630964588.davem@davemloft.net>
         <1490763787.3177.168.camel@kernel.crashing.org>
         <20170328.221027.1436005565229924031.davem@davemloft.net>
         <1490764697.3177.170.camel@kernel.crashing.org>
         <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
         <1490821714.3177.189.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45660 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932757AbdC3Aq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:46:27 -0400
In-Reply-To: <1490821714.3177.189.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-30 at 08:08 +1100, Benjamin Herrenschmidt wrote:
> On Wed, 2017-03-29 at 11:08 -0700, Florian Fainelli wrote:
> > I hear your point that you are the only users of the driver and
> > it's
> > already in a bad shape, but take this as an opportunity to increase
> > your commit count ;)
> 
> Haha, my commit count is fine thanks ;-)
> 
> I'll see what I can do. I need to respin anyway, I haven't tested
> the netpoll support and it doesn't build (ugh). So I'll try to break
> it down. Maybe not 200 patches but I'll see if I can make it more
> palatable.

FYI, Dave, Florian

I've started re-doing the work in the form of a series of patches.

I can't promise I'll manage to make them all really small but I'll
do my best. So hold onto reviewing if you haven't started already.

The end result will, I hope, be identical.

Cheers,
Ben.
