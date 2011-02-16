From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC !!BONUS!! PATCH 6/5] ipv4: Delete routing cache.
Date: Wed, 16 Feb 2011 08:56:17 +0100
Message-ID: <1297842977.3201.7.camel@edumazet-laptop>
References: <20110209.223939.246547003.davem@davemloft.net>
	 <20110215.185534.71133854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48764 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab1BPH4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 02:56:25 -0500
Received: by bwz15 with SMTP id 15so361599bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 23:56:23 -0800 (PST)
In-Reply-To: <20110215.185534.71133854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 f=C3=A9vrier 2011 =C3=A0 18:55 -0800, David Miller a =C3=A9=
crit :
> From: David Miller <davem@davemloft.net>
> Date: Wed, 09 Feb 2011 22:39:39 -0800 (PST)
>=20
> >=20
> > Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Ok, this patch had one nasty bug:
>=20
> > +	if (!err =3D=3D 0)
>=20
> Yeah... right.
>=20
> I'm actively testing this version at the moment, against net-next-2.6=
,
> works fine thus far.
>=20
> --------------------
> ipv4: Delete routing cache.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

I suspect we can zap DST_NOCACHE later ?



