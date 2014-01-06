From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and
 protect forwarding path against pmtu spoofing
Date: Mon, 06 Jan 2014 16:08:46 -0500 (EST)
Message-ID: <20140106.160846.544525591241855516.davem@davemloft.net>
References: <20140106084827.GA5766@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979AbaAFVIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:08:49 -0500
In-Reply-To: <20140106084827.GA5766@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 6 Jan 2014 09:48:27 +0100

> I want to put these patches up for discussion again. I did more testing
> to them (xfrm, tunnel), did some rewording and rewrote the IPv6 patch.

I'm still thinking about this series.

I would have been nice if you provided a "0/3" introductory posting
discussing your point of view, and giving a more detailed analysis of
your view of the situation so that John and others have something to
reply to.

Thanks.
