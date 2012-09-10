From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: add MOD operation
Date: Mon, 10 Sep 2012 15:45:37 -0400 (EDT)
Message-ID: <20120910.154537.639794042526369471.davem@davemloft.net>
References: <20120907074910.2df46817@arrowsmith>
	<20120908030311.GM17289@tassilo.jf.intel.com>
	<1347091415.1234.317.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, gbakos@alpinista.org, jschlst@samba.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab2IJTpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:45:39 -0400
In-Reply-To: <1347091415.1234.317.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 Sep 2012 10:03:35 +0200

> From: Eric Dumazet <edumazet@google.com>
 ...
> [PATCH net-next] filter: add MOD operation
> 
> Add a new ALU opcode, to compute a modulus.
> 
> Commit ffe06c17afbbb used an ancillary to implement XOR_X,
> but here we reserve one of the available ALU opcode to implement both
> MOD_X and MOD_K
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Suggested-by: George Bakos <gbakos@alpinista.org>
> Cc: Jay Schulist <jschlst@samba.org>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Cc: Andi Kleen <ak@linux.intel.com>

Applied to net-next, thanks.
