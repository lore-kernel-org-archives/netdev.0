From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 12:04:13 +0100
Message-ID: <1209639853.4191.25.camel@moonstone.uk.level5networks.com>
References: <20080501.033414.132094744.davem@davemloft.net>
	 <20080501103854.GA7285@gondor.apana.org.au>
	 <20080501104517.GA7390@gondor.apana.org.au>
	 <20080501.035204.147190700.davem@davemloft.net>
	 <20080501105503.GB7490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:2691 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210AbYEALPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 07:15:45 -0400
In-Reply-To: <20080501105503.GB7490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-01 at 18:55 +0800, Herbert Xu wrote:
> So what we want to detect/forbid isn't the forwarding of GSO
> packets, but the LRO of packets which aren't destined for the
> local host.

That's correct as I understand it.

Kieran

