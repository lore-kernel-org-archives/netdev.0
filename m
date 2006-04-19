From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP]: Fix truesize underflow
Date: Wed, 19 Apr 2006 16:40:51 +1000
Message-ID: <20060419064051.GA14313@gondor.apana.org.au>
References: <20060418123204.GA3962@gondor.apana.org.au> <20060418.132256.110004342.davem@davemloft.net> <20060418232713.GA11938@gondor.apana.org.au> <4445D305.8080505@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kernel@linuxace.com,
	nipsy@bitgnome.net, jesse.brandeburg@intel.com,
	jrlundgren@gmail.com, cat@zip.com.au, djani22@dynamicweb.hu,
	yoseph.basri@gmail.com, mykleb@no.ibm.com, olel@ans.pl,
	michal@feix.cz, chris@scorpion.nl, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22532 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750796AbWDSGmH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 02:42:07 -0400
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Content-Disposition: inline
In-Reply-To: <4445D305.8080505@kernelpanic.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2006 at 10:04:53AM +0400, Boris B. Zhmurov wrote:
> 
> I confirm, finally I don't see messages in dmesg about assertions. Nice 
> work :)

That's great.  Thanks a lot for your and everyone else's help in
tracking down.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
