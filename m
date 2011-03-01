From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/5] net: Remove unused sk_sndmsg_* from UFO
Date: Tue, 01 Mar 2011 06:31:01 +0100
Message-ID: <1298957461.2676.8.camel@edumazet-laptop>
References: <20110227110614.GA6246@gondor.apana.org.au>
	 <E1Pu1TI-0005Qa-KA@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	Thomas Graf <tgraf@infradead.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37414 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab1CAFbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 00:31:05 -0500
Received: by mail-wy0-f174.google.com with SMTP id 36so4346663wyg.19
        for <netdev@vger.kernel.org>; Mon, 28 Feb 2011 21:31:04 -0800 (PST)
In-Reply-To: <E1Pu1TI-0005Qa-KA@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 19:41 +0800, Herbert Xu a =C3=A9cr=
it :
> net: Remove unused sk_sndmsg_* from UFO
>=20
> UFO doesn't really use the sk_sndmsg_* parameters so touching
> them is pointless.  It can't use them anyway since the whole
> point of UFO is to use the original pages without copying.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


