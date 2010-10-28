From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 10:29:17 -0700 (PDT)
Message-ID: <20101028.102917.246527148.davem@davemloft.net>
References: <4CC99FDC.9070102@parallels.com>
	<1288283634.11523.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933260Ab0J1R2x convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 13:28:53 -0400
In-Reply-To: <1288283634.11523.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Oct 2010 18:33:54 +0200

> Le jeudi 28 octobre 2010 =E0 20:07 +0400, Pavel Emelyanov a =E9crit :
>> commit e985aad7 (ip_gre: percpu stats accounting) forgot the fallbac=
k
>> tunnel case (gre0).
>>=20
>> This is the 4th part of the "foo: fix percpu stats accounting" serie=
s ;)
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>=20
>=20
> Indeed, right you are ;)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
