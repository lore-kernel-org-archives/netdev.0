From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Tue, 11 Sep 2007 20:43:27 +0800
Message-ID: <20070911124327.GA6183@gondor.apana.org.au>
References: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de> <20070910130024.GA27939@gondor.apana.org.au> <1189469081.14002.3.camel@localhost> <20070911021812.GA1544@gondor.apana.org.au> <1189512106.4231.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4911 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762464AbXIKMns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 08:43:48 -0400
Content-Disposition: inline
In-Reply-To: <1189512106.4231.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 11, 2007 at 08:01:46AM -0400, jamal wrote:
>
> [NET_SCHED] protect action config/dump from irqs

Looks good! Thanks Jamal.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
