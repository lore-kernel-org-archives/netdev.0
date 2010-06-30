From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: use stack variable
Date: Wed, 30 Jun 2010 18:30:05 +0800
Message-ID: <20100630103005.GA24688@gondor.apana.org.au>
References: <1277888829-30230-1-git-send-email-xiaosuo@gmail.com> <1277893521.3509.17.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54860 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab0F3KaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 06:30:14 -0400
Content-Disposition: inline
In-Reply-To: <1277893521.3509.17.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 06:25:21AM -0400, jamal wrote:
> On Wed, 2010-06-30 at 17:07 +0800, Changli Gao wrote:
> > act_nat: use stack variable
> > 
> > structure tc_nat isn't too big for stack, so we can put it in stack.
> > 
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Doesnt look unreasonable - will let Herbert make the call..

Looks good to me too.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
