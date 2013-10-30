From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 12:53:06 -0700
Message-ID: <1383162786.4857.53.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.220253.1263087684709722001.davem@davemloft.net>
	 <20131030020543.GA1925@gondor.apana.org.au>
	 <1383161957.1601.27.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35879 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792Ab3J3TxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:53:08 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so1426946pdj.6
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 12:53:08 -0700 (PDT)
In-Reply-To: <1383161957.1601.27.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 19:39 +0000, Ben Hutchings wrote:

> I think the change to enable mega-GRO packets should be reverted and
> that change should go to stable so that the performance regression for
> forwarding is also fixed.

What are you talking about ?

The change is in net-next only.

It seems a lot of people talk, but few people try to help.
