From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 06:33:21 +0100
Message-ID: <1298957601.2676.12.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:54819 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab1CAFd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:33:26 -0500
Received: by wwe15 with SMTP id 15so4024827wwe.1
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:33:25 -0800 (PST)
In-Reply-To: <20110228113659.GA20726@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:36 +0800, Herbert Xu a =C3=A9cr=
it :

> Here are the patches I used.  Please don't them yet as I intend
> to clean them up quite a bit.
>=20

I assume you mean "please dont commit them" ;)

> But please do test them heavily, especially if you have an AMD
> NUMA machine as that's where scalability problems really show
> up.  Intel tends to be a lot more forgiving.  My last AMD machine
> blew up years ago :)

Same here, My only AMD machine is a desktop class machine, not a server=
=2E



