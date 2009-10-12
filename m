From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
 (v4)
Date: Mon, 12 Oct 2009 03:01:29 -0700 (PDT)
Message-ID: <20091012.030129.51619515.davem@davemloft.net>
References: <20091007180835.GB20524@hmsreliant.think-freely.org>
	<20091010123522.GA24193@localhost.localdomain>
	<4AD2B2BF.8040706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209AbZJLKBd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 06:01:33 -0400
In-Reply-To: <4AD2B2BF.8040706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 12 Oct 2009 06:38:23 +0200

> Neil Horman a =E9crit :
>> 3) This applies cleanly to net-next assuming that commit
>> 977750076d98c7ff6cbda51858bb5a5894a9d9ab (my af packet cmsg patch) i=
s reverted
>>=20
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
> Thanks Neil
>=20
> I found no obvious error in this v4, except two long lines.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I reverted the AF_PACKET commit and applied this patch,
thanks!
