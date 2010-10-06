From: David Miller <davem@davemloft.net>
Subject: Re: Regarding to your linux kernel CL
Date: Wed, 06 Oct 2010 01:14:48 -0700 (PDT)
Message-ID: <20101006.011448.112578977.davem@davemloft.net>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com>
	<4CAC1F20.6070009@iki.fi>
	<20101006075946.GA5311@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, cywang@google.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757240Ab0JFIO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 04:14:27 -0400
In-Reply-To: <20101006075946.GA5311@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 6 Oct 2010 15:59:46 +0800

> Perhaps we should move the genid/cookie logic into the dst so that
> we can eliminate the dst->check call or at least make it a lot less
> frequent.

That sounds like a good idea.
