From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [stable] [PATCH 2.6.21-stable] [IPV6]: Restore semantics of
	Routing Header processing.
Date: Wed, 16 May 2007 19:12:18 -0700
Message-ID: <20070517021218.GF3429@sequoia.sous-sol.org>
References: <20070511162243.GC3516@sequoia.sous-sol.org> <20070512.012820.126195303.yoshfuji@linux-ipv6.org> <20070517014600.GE3429@sequoia.sous-sol.org> <20070516.191013.102573773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:49036 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758250AbXEQCNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 22:13:44 -0400
Content-Disposition: inline
In-Reply-To: <20070516.191013.102573773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller (davem@davemloft.net) wrote:
> We're not pushing this in, even the ipv6 working group is unsure
> how this should be handled and one of the possibilities they might
> choose matches how things currently are.

Alright, I'll drop this one from the -stable radar, thanks.
-chris
