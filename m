From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 04 Jun 2015 13:44:12 -0700
Message-ID: <1433450652.1895.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150516131628.GA981@gondor.apana.org.au>
	 <20150516.171019.1206903516753105739.davem@davemloft.net>
	 <20150604162727.GA2670@roeck-us.net>
	 <20150604.115922.1489867293287036693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, herbert@gondor.apana.org.au, tgraf@suug.ch,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34339 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbbFDUoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 16:44:14 -0400
Received: by igbhj9 with SMTP id hj9so989713igb.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 13:44:14 -0700 (PDT)
In-Reply-To: <20150604.115922.1489867293287036693.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-04 at 11:59 -0700, David Miller wrote:
> From: Guenter Roeck <linux@roeck-us.net>
> Date: Thu, 4 Jun 2015 09:27:27 -0700
> 
> > sorry for bothering you - I don't see this patch in any of your trees,
> > and it is marked as "changes requested" in patchwork. Did I look
> > at the wrong places, do you still plan to apply the patch as-is,
> > or do you expect some changes ?
> > 
> > As side info, I have been trying to track down the getaddrinfo
> > hang problem observed by others, which we see in 3.19.4 and 4.0.4.
> 
> Changes-requested, amazingly, means that someone gave you feedback
> and changes along with a fresh resubmission is expected of you.

Arg.

I hope Herbert can sort out this soon enough, I thought patch was
already queued.

Thanks.
