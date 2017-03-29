From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Thu, 30 Mar 2017 08:08:34 +1100
Message-ID: <1490821714.3177.189.camel@kernel.crashing.org>
References: <1490762446.3177.164.camel@kernel.crashing.org>
         <20170328.215744.794906222630964588.davem@davemloft.net>
         <1490763787.3177.168.camel@kernel.crashing.org>
         <20170328.221027.1436005565229924031.davem@davemloft.net>
         <1490764697.3177.170.camel@kernel.crashing.org>
         <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57102 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932704AbdC2VIp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 17:08:45 -0400
In-Reply-To: <e019331d-7050-ca6d-7f27-73878e290f7a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 11:08 -0700, Florian Fainelli wrote:
> I hear your point that you are the only users of the driver and it's
> already in a bad shape, but take this as an opportunity to increase
> your commit count ;)

Haha, my commit count is fine thanks ;-)

I'll see what I can do. I need to respin anyway, I haven't tested
the netpoll support and it doesn't build (ugh). So I'll try to break
it down. Maybe not 200 patches but I'll see if I can make it more
palatable.

Cheers,
Ben.
