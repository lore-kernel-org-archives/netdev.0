From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Mon, 27 Apr 2009 19:01:36 +0800
Message-ID: <20090427110136.GA22960@gondor.apana.org.au>
References: <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090427080735.GA21493@gondor.apana.org.au> <20090427.023241.171629284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gallatin@myri.com, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34609 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752297AbZD0LBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 07:01:43 -0400
Content-Disposition: inline
In-Reply-To: <20090427.023241.171629284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 02:32:41AM -0700, David Miller wrote:
>
> These look good, want me to toss them into net-next-2.6?

Yes please.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
