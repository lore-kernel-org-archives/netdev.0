From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Mon, 19 Jan 2009 22:16:56 +1100
Message-ID: <20090119111656.GB2575@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au> <20090113092828.GA28052@gondor.apana.org.au> <20090118.214729.257523668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41575 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756264AbZASLRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 06:17:01 -0500
Content-Disposition: inline
In-Reply-To: <20090118.214729.257523668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 09:47:29PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 13 Jan 2009 20:28:28 +1100
> 
> > igb: Replace LRO with GRO
>  ...
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Have the crashes reported by Intel been sorted out yet?
> If so, I'll queue this up for 2.6.30
> 
> Otherwise please resubmit once the problem is resolved.

I believe it should be cured.  But it wouldn't hurt to wait for
them to reconfirm.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
