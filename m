From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 1/2] inet: generalize ipv4-only RFC3168 5.3 ecn
 fragmentation handling for future use by ipv6
Date: Sun, 24 Mar 2013 21:23:15 +0900
Message-ID: <514EF033.1000807@linux-ipv6.org>
References: <20130322182437.GC19365@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jbrouer@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43022 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753410Ab3CXMXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 08:23:19 -0400
In-Reply-To: <20130322182437.GC19365@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This patch just moves some code arround to make the ip4_frag_ecn_table
> and IPFRAG_ECN_* constants accessible from the other reassembly engines. I
> also renamed ip4_frag_ecn_table to ip_frag_ecn_table.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>


--yoshfuji
