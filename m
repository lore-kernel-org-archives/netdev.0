From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 17:48:41 +1100
Message-ID: <20090116064840.GA12399@gondor.apana.org.au>
References: <8CB45B537A78CBC-E08-15F7@webmail-stg-d04.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jpo234@netscape.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33375 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752205AbZAPGso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 01:48:44 -0500
Content-Disposition: inline
In-Reply-To: <8CB45B537A78CBC-E08-15F7@webmail-stg-d04.sysops.aol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jpo234@netscape.net wrote:
>
> So, if you write "should have the same effect as IP_HDRINCL" does this 
> mean "this is the way we designed it in Linux, so it should work" or 

It's designed this way in Linux.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
