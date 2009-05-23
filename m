From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Sat, 23 May 2009 09:32:01 +0200
Message-ID: <20090523073201.GA2766@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com> <20090521085116.GC2892@ami.dom.local> <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:61968 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbZEWHcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 03:32:43 -0400
Received: by bwz22 with SMTP id 22so2026727bwz.37
        for <netdev@vger.kernel.org>; Sat, 23 May 2009 00:32:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 22, 2009 at 06:42:16PM +0100, Antonio Almeida wrote:
> On Thu, May 21, 2009 at 9:51 AM, Jarek Poplawski wrote:
> > I still have no clue about the reason, but it would be really nice to
> > do some short test with more current kernel (>= 2.6.27) and iproute2
> > (to exclude the possibility of some incomaptibility in configs e.g.
> > rate tables passed to htb).
> 
> I installed kernel 2.6.29 (finaly! wasn't easy... I couldn't set
> memory split 2G/2G),
> but the results are the same. I've already applied gen_estimator.c
> patches (works fine).
...
> I'm working on a newer iproute2.

Actually, from these two I was more interested in iproute2 more
fitting the kernel version. :-((It should be enough to have at least
tc compiled properly, I guess.)

Btw.: if at any point you think this testing is too disturbing to you
etc., feel free to stop this or delay in time as you like.

Thanks,
Jarek P.
