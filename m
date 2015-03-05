From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: gro: remove obsolete code from
 skb_gro_receive()
Date: Thu, 05 Mar 2015 13:04:18 -0800
Message-ID: <1425589458.5130.264.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425493600.5130.208.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150305.160028.1421983637301031004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33054 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbbCEVEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 16:04:21 -0500
Received: by iecar1 with SMTP id ar1so80244734iec.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 13:04:20 -0800 (PST)
In-Reply-To: <20150305.160028.1421983637301031004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-05 at 16:00 -0500, David Miller wrote:

> Please get rid of the local variables that are no made unused by this
> change:
>=20
> net/core/skbuff.c: In function =E2=80=98skb_gro_receive=E2=80=99:
> net/core/skbuff.c:3212:15: warning: unused variable =E2=80=98headroom=
=E2=80=99 [-Wunused-variable]
> net/core/skbuff.c:3209:18: warning: unused variable =E2=80=98nskb=E2=80=
=99 [-Wunused-variable]

Hmpff... I sent the wrong patch it seems. Sorry.

Will fix this after my lunch ;)
