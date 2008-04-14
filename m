From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-2.6.26] [IPV6] Add stats in multicast routing
 module method ip6_mr_forward().
Date: Sun, 13 Apr 2008 23:59:23 -0700 (PDT)
Message-ID: <20080413.235923.165543927.davem@davemloft.net>
References: <eb3ff54b0804101121lf741824xb875cf49a2629cc6@mail.gmail.com>
	<20080413.231806.221764599.davem@davemloft.net>
	<20080414.155916.22280629.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753564AbYDNG7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:59:22 -0400
In-Reply-To: <20080414.155916.22280629.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Apr 2008 15:59:16 +0900 (JST)

> In article <20080413.231806.221764599.davem@davemloft.net> (at Sun, 13 Apr 2008 23:18:06 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: "Rami Rosen" <ramirose@gmail.com>
> > Date: Thu, 10 Apr 2008 21:21:12 +0300
> > 
> > >   This patches adds a call to increment IPSTATS_MIB_OUTFORWDATAGRAMS
> > >    when forwarding the packet in ip6_mr_forward() in the IPv6
> > > multicast routing module (net/ipv6/ip6mr.c).
> > > 	
> > > Signed-off-by: Rami Rosen <ramirose@gmail.com>
> > 
> > This looks OK to me, but I'll let Yoshifuji pick it up.
> 
> I'm okay with it.
> Here it is.

Applied, thank you.
