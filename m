From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with ipcomp
Date: Fri, 8 Feb 2008 19:58:36 +1100
Message-ID: <20080208085836.GC14650@gondor.apana.org.au>
References: <3C59DB883F7B0B4D8096010D45ACCD134F20BB@exch.facton.local> <20080206170717.GA20308@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20C0@exch.facton.local> <20080207154437.GA7237@gondor.apana.org.au> <3C59DB883F7B0B4D8096010D45ACCD134F20CE@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40066 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753328AbYBHI6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 03:58:40 -0500
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F20CE@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2008 at 07:01:32PM +0100, Beschorner Daniel wrote:
>
> > Could you show me the exact policies/SAs of the tunnel involved
> > in the crash?
> 
> esp/cbc(aes128)/hmac(sha1)

No I meant the exact output of ip x p and ip x s.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
