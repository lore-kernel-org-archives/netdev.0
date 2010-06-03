From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Thu, 3 Jun 2010 23:00:11 +1000
Message-ID: <20100603130011.GA695@gondor.apana.org.au>
References: <20100525124636.GA13161@gondor.apana.org.au> <1274793216.3878.947.camel@bigi> <20100525231307.GA19475@gondor.apana.org.au> <1274873881.3878.988.camel@bigi> <1275226150.3587.9.camel@bigi> <20100603080130.GA29709@gondor.apana.org.au> <1275569030.3445.49.camel@bigi> <20100603124717.GB315@gondor.apana.org.au> <1275569594.3445.51.camel@bigi> <1275569896.3445.53.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42147 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752333Ab0FCNAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 09:00:19 -0400
Content-Disposition: inline
In-Reply-To: <1275569896.3445.53.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 08:58:16AM -0400, jamal wrote:
>
> Never mind. You did answer this question above. You are saying it is
> guaranteed.
> I will send patches to remove the checks in both pedit and handle_ing().
> At some point i will test it....

Thanks Jamal!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
