From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 14:06:16 +0100
Message-ID: <20140106130616.GA8187@localhost>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
 <1388963586-5049-2-git-send-email-pablo@netfilter.org>
 <20140105234157.GB29910@order.stressinduktion.org>
 <20140106115436.GE28854@breakpoint.cc>
 <20140106124340.GC4611@order.stressinduktion.org>
 <20140106130451.GF28854@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56972 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbaAFNGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:06:21 -0500
Content-Disposition: inline
In-Reply-To: <20140106130451.GF28854@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 02:04:51PM +0100, Florian Westphal wrote:
> Pablo/David, if you think this needs to be fixed RIGHT NOW then please
> just issue a revert for a42b99a6e329654d376b330de057eff87686d890.

I just did it, thanks Florian.
