From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/2] udpv4: Support software UFO and handle large
	incoming UDP/IPv4 packets
Date: Thu, 25 Jun 2009 16:01:53 +0800
Message-ID: <20090625080152.GA32497@gondor.apana.org.au>
References: <1245860210.23459.13.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36005 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751679AbZFYIB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 04:01:58 -0400
Content-Disposition: inline
In-Reply-To: <1245860210.23459.13.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 09:16:50AM -0700, Sridhar Samudrala wrote:
> [RFC 1/2] udpv4: Support software UFO and handle large incoming UDP/IPv4 packets
> 
> - validate and forward GSO UDP/IPv4 packets from untrusted sources(guests under KVM).
> - do software UFO if the outgoing device doesn't support UFO.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Looks good to me.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
