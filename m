From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 10:35:34 +1100
Message-ID: <20070115233534.GB11037@gondor.apana.org.au>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2167 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932119AbXAOXfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 18:35:36 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45ABF620.3070405@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 12:46:08AM +0300, Michael Tokarev wrote:
> 
> I'm doing the capture on an intermediate host - the whole day today ;)

Cool, I was just trying to make sure :)
 
> The trace is here: http://www.corpit.ru/mjt/bad-tcp-cksum-dmp.bin

I'll take a look.

Are you using anything extra like netfilter?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
