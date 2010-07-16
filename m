From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: sizeof struct tcp_skb_cb is 44
Date: Thu, 15 Jul 2010 21:41:12 -0700 (PDT)
Message-ID: <20100715.214112.241430854.davem@davemloft.net>
References: <1279254059.2433.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48623
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751842Ab0GPEk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 00:40:56 -0400
In-Reply-To: <1279254059.2433.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Jul 2010 06:20:59 +0200

> Correct comment stating sizeof(struct tcp_skb_cb) is 36 or 40, since its
> 44 bytes, since commit 951dbc8ac714b04 ([IPV6]: Move nextheader offset
> to the IP6CB).
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
