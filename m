From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] xfrm: fix xfrm by MARK logic
Date: Sat, 03 Jul 2010 08:38:03 +0200
Message-ID: <1278139083.2474.42.camel@edumazet-laptop>
References: <20100702174755.GA12509@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter Kosyh <p.kosyh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64540 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab0GCGiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 02:38:08 -0400
Received: by wwb24 with SMTP id 24so765463wwb.1
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 23:38:06 -0700 (PDT)
In-Reply-To: <20100702174755.GA12509@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 juillet 2010 =C3=A0 21:47 +0400, Peter Kosyh a =C3=A9cri=
t :
> From: Peter Kosyh <p.kosyh@gmail.com>
>=20
> While using xfrm by MARK feature in
> 2.6.34 - 2.6.35 kernels, the mark=20
> is always cleared in flowi structure via memset in=20
> _decode_session4 (net/ipv4/xfrm4_policy.c), so
> the policy lookup fails.
> IPv6 code is affected by this bug too.
>=20
> Signed-off-by: Peter Kosyh <p.kosyh@gmail.com>
> ---
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


