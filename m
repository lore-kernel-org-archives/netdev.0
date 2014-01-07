From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Tue, 7 Jan 2014 01:11:03 +0100
Message-ID: <20140107001103.GE10204@order.stressinduktion.org>
References: <20140106084827.GA5766@order.stressinduktion.org> <20140106.160846.544525591241855516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43788 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932755AbaAGALF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 19:11:05 -0500
Content-Disposition: inline
In-Reply-To: <20140106.160846.544525591241855516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 04:08:46PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 6 Jan 2014 09:48:27 +0100
> 
> > I want to put these patches up for discussion again. I did more testing
> > to them (xfrm, tunnel), did some rewording and rewrote the IPv6 patch.
> 
> I'm still thinking about this series.
> 
> I would have been nice if you provided a "0/3" introductory posting
> discussing your point of view, and giving a more detailed analysis of
> your view of the situation so that John and others have something to
> reply to.

I'll do next time, sorry.

I am around for discussion. Have you seen that Steffen did test these
patches with his pmtu testsuite successfully and they showed no obvious
regressions (he posted to the old thread)?

Thanks,

  Hannes
