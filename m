From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove ipv6_statistics
Date: Fri, 25 Jun 2010 21:34:48 -0700 (PDT)
Message-ID: <20100625.213448.55843681.davem@davemloft.net>
References: <1277297485.2469.584.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, den@openvz.org,
	adobriyan@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51861
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751033Ab0FZEef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:34:35 -0400
In-Reply-To: <1277297485.2469.584.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jun 2010 14:51:25 +0200

> commit 9261e5370112 (ipv6: making ip and icmp statistics per/namespace)
> forgot to remove ipv6_statistics variable.
> 
> commit bc417d99bf27 (ipv6: remove stale MIB definitions) took care of
> icmpv6_statistics & icmpv6msg_statistics
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
