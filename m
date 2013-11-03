From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 09:26:43 -0800
Message-ID: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41322 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684Ab3KCR0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 12:26:44 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so5993997pab.26
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 09:26:44 -0800 (PST)
In-Reply-To: <20131103163103.GA18894@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 00:31 +0800, Herbert Xu wrote:

> I give up.  It's as if you've ignored everything I've said before.

Not really.

Have you took a look at the GSO path recently ?

The days it was handling only IP+TCP are gone.

If you think you can do better, please do so.
