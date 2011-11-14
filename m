From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V5 net-next] neigh: new unresolved queue limits
Date: Mon, 14 Nov 2011 07:54:07 +0100
Message-ID: <1321253647.17837.63.camel@edumazet-laptop>
References: <20111109.161644.505896539772671525.davem@davemloft.net>
	 <20111109.162137.808999062815992591.davem@davemloft.net>
	 <1320876434.3272.12.camel@edumazet-laptop>
	 <20111114.004813.220637143497418040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42604 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1KNGyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 01:54:12 -0500
Received: by wyh15 with SMTP id 15so5551376wyh.19
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2011 22:54:11 -0800 (PST)
In-Reply-To: <20111114.004813.220637143497418040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 00:48 -0500, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 09 Nov 2011 23:07:14 +0100
>=20
> > Ouch, this was fixed on one machine yesterday, but not the other on=
e I
> > used this morning, sorry.
> >=20
> > [PATCH V5 net-next] neigh: new unresolved queue limits
>=20
> Applied, thanks Eric.

Hi David

I realize changelog was truncated, because it contained a copy of ping
message (--- 192.168.20.108 ping statistics ---)

Normally, the marker line should contains only "---", it seems patchwor=
k
has a too strict behavior ?

Thanks
