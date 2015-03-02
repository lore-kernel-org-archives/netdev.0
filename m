From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter updates for net-next
Date: Mon, 02 Mar 2015 14:55:30 -0500 (EST)
Message-ID: <20150302.145530.168636281637118075.davem@davemloft.net>
References: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  2 Mar 2015 12:43:42 +0100

> A small batch with accumulated updates in nf-next, mostly IPVS updates,
> they are:
> 
> 1) Add 64-bits stats counters to IPVS, from Julian Anastasov.
> 
> 2) Move NETFILTER_XT_MATCH_ADDRTYPE out of NETFILTER_ADVANCED as docker
> seem to require this, from Anton Blanchard.
> 
> 3) Use boolean instead of numeric value in set_match_v*(), from
> coccinelle via Fengguang Wu.
> 
> 4) Allows rescheduling of new connections in IPVS when port reuse is
> detected, from Marcelo Ricardo Leitner.
> 
> 5) Add missing bits to support arptables extensions from nft_compat,
> from Arturo Borrero.
> 
> Patrick is preparing a large batch to enhance the set infrastructure,
> named expressions among other things, that should follow up soon after
> this batch.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks a lot Pablo.
