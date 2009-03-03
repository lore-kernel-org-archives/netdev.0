From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING: at net/core/dev.c:1505 skb_gso_segment+0x6e/0x156()
Date: Tue, 3 Mar 2009 10:25:54 +0800
Message-ID: <20090303022554.GA26217@gondor.apana.org.au>
References: <20090302041542.GA15961@gondor.apana.org.au> <Pine.LNX.4.64.0903021211120.28055@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55036 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751618AbZCCCZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 21:25:59 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903021211120.28055@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 12:32:32PM -0800, Chris Stromsoe wrote:
>
> I am not seeing the warnings with 2.6.28.7 on the same hardware.  Did you 
> want me to try with one of the 2.6..28-rcX kernels, or was that a typo 
> for 2.6.29-rcX ?

Sorry, I meant 2.6.29-rcX.

If you're no longer seeing it with 2.6.28.7, then it's most likely
the result of a features computation bug that's already fixed.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
