From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 2/2] ipv6: implement RFC3168 5.3 (ecn protection)
 for ipv6 fragmentation handling
Date: Sun, 24 Mar 2013 21:28:15 +0900
Message-ID: <514EF15F.9090009@linux-ipv6.org>
References: <20130322182444.GA939@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jbrouer@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43150 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753629Ab3CXM2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 08:28:18 -0400
In-Reply-To: <20130322182444.GA939@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:

> [PATCH 2/2] ipv6: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling
> 
> This patch also ensures that INET_ECN_CE is propagated if one fragment
> had the codepoint set.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
