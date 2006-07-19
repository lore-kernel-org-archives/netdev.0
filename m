From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: michael_mic in crypto api?
Date: Thu, 20 Jul 2006 03:05:10 +1000
Message-ID: <E1G3FTy-0002Ps-00@gondolin.me.apana.org.au>
References: <20060719161913.GA15317@instant802.com>
Cc: herbert@gondor.apana.org.au, flamingice@sourmilk.net,
	jbenc@suse.cz, linville@tuxdriver.com, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60684 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030204AbWGSRFk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 13:05:40 -0400
To: jkm@devicescape.com (Jouni Malinen)
In-Reply-To: <20060719161913.GA15317@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen <jkm@devicescape.com> wrote:
>
> However, at least for some time, there are two different TKIP
> implementations (net/ieee80211 and net/d80211) so this would mean
> duplicating Michael MIC implementation and I would rather not do that.

Good point, let's keep it for now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
