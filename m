From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH net-2.6.24] [L2TP] Fix lockup introduced by recent changes
Date: Wed, 19 Sep 2007 09:37:40 +0800
Message-ID: <20070919013740.GD15046@gondor.apana.org.au>
References: <200709182144.l8ILiXrx008249@quickie.katalix.com> <20070918.145106.91759702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
	mostrows@speakeasy.net, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3171 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750933AbXISBh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 21:37:56 -0400
Content-Disposition: inline
In-Reply-To: <20070918.145106.91759702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2007 at 02:51:06PM -0700, David Miller wrote:
> 
> Herbert, please take a quick look, thanks.

Yep it looks good.  I should've read my emails from the
bottom up :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
