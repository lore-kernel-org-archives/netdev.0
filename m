From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Flush per-ns routing cache more sanely.
Date: Mon, 20 Dec 2010 10:36:07 -0800 (PST)
Message-ID: <20101220.103607.189701280.davem@davemloft.net>
References: <1288121422.2652.14.camel@edumazet-laptop>
	<20101219.211453.226783693.davem@davemloft.net>
	<1292865233.2800.192.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	daniel.lezcano@free.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932563Ab0LTSfi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Dec 2010 13:35:38 -0500
In-Reply-To: <1292865233.2800.192.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Dec 2010 18:13:53 +0100

> Le dimanche 19 d=E9cembre 2010 =E0 21:14 -0800, David Miller a =E9cri=
t :
>> ipv4: Flush per-ns routing cache more sanely.
>>=20
>> Flush the routing cache only of entries that match the
>> network namespace in which the purge event occurred.
>>=20
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> Seems fine to me, thanks !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks for reviewing.
