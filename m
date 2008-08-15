From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for	iptables nat routing
Date: Fri, 15 Aug 2008 18:14:42 +1000
Message-ID: <20080815081442.GA20971@gondor.apana.org.au>
References: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au> <1218778238.23510.22.camel@2710p.home> <20080815073343.GA20644@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36773 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754376AbYHOIOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 04:14:55 -0400
Content-Disposition: inline
In-Reply-To: <20080815073343.GA20644@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 05:33:43PM +1000, Herbert Xu wrote:
> On Thu, Aug 14, 2008 at 11:30:37PM -0600, Alex Williamson wrote:
> >
> > Here it is.  Thanks,
> 
> Can you also post all your netfilter rules (filter + NAT) please?

It's OK, I can reproduce it now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
