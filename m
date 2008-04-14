From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-2.6.26] [IPV6] Add stats in multicast routing
 module method ip6_mr_forward().
Date: Sun, 13 Apr 2008 23:18:06 -0700 (PDT)
Message-ID: <20080413.231806.221764599.davem@davemloft.net>
References: <eb3ff54b0804101121lf741824xb875cf49a2629cc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753083AbYDNGSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:18:05 -0400
In-Reply-To: <eb3ff54b0804101121lf741824xb875cf49a2629cc6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Thu, 10 Apr 2008 21:21:12 +0300

>   This patches adds a call to increment IPSTATS_MIB_OUTFORWDATAGRAMS
>    when forwarding the packet in ip6_mr_forward() in the IPv6
> multicast routing module (net/ipv6/ip6mr.c).
> 	
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

This looks OK to me, but I'll let Yoshifuji pick it up.
