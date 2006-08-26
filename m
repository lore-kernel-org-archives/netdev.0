From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec kernel oops on ppc64
Date: Sat, 26 Aug 2006 16:48:34 +1000
Message-ID: <E1GGry6-00048P-00@gondolin.me.apana.org.au>
References: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
Cc: netdev@vger.kernel.org, gcwilson@us.ibm.com, jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42770 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964915AbWHZGse
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 02:48:34 -0400
To: latten@austin.ibm.com (Joy Latten)
In-Reply-To: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joy Latten <latten@austin.ibm.com> wrote:
> I installed 2.6.17 + patch-2.6.18-rc4 + 2.6.18-rc4-mm2
> onto two pSeries power 5 (ppc64 lpars) machines. I configured
> IPSec using the configuration listed below. 

Could you try straight 2.6.17? If that crashes too, then at least we
can be sure that it isn't something new.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
