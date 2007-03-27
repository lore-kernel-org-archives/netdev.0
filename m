From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Allow partial checksums to be forwarded
Date: Tue, 27 Mar 2007 15:11:01 +1000
Message-ID: <20070327051101.GA22216@gondor.apana.org.au>
References: <20070327043648.GA21558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964784AbXC0FLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 01:11:03 -0400
Content-Disposition: inline
In-Reply-To: <20070327043648.GA21558@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 02:36:48PM +1000, Herbert Xu wrote:
> 
> Looks like I forgot to finish the checksum stuff for Xen last time around.
> 
> [NET]: Allow partial checksums to be forwarded

Hang on, this only gets rid of half the hack.  Let me change this
first so that we can get rid of them all :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
