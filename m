From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6.18-rc4] lockdep warning at inet6_addr_add
Date: Sat, 12 Aug 2006 13:14:00 +1000
Message-ID: <E1GBjwm-0004pd-00@gondolin.me.apana.org.au>
References: <20060811162352.GA14795@dreamland.darkstar.lan>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41735 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750811AbWHLDOD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 23:14:03 -0400
To: kornos.it@gmail.com (Luca)
In-Reply-To: <20060811162352.GA14795@dreamland.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luca <kornos.it@gmail.com> wrote:
> I get a warning from lockdep during boot; 2.6.18-rc3 don't have this
> warning. I see a similar report in the archive (I haven't found time to
> test the patch...):
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115506258902757&w=2

It's the same issue.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
