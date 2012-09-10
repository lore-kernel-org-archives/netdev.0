From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x86 bpf_jit: support MOD operation
Date: Mon, 10 Sep 2012 17:09:17 -0400 (EDT)
Message-ID: <20120910.170917.1410737762281696625.davem@davemloft.net>
References: <1347091415.1234.317.camel@edumazet-glaptop>
	<20120910.154537.639794042526369471.davem@davemloft.net>
	<1347310113.13103.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, gbakos@alpinista.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752888Ab2IJVJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 17:09:22 -0400
In-Reply-To: <1347310113.13103.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Sep 2012 22:48:33 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit b6069a9570 (filter: add MOD operation) added generic
> support for modulus operation in BPF.
> 
> This patch brings JIT support for x86_64
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
