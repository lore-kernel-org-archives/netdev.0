From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 20:38:58 +0200
Message-ID: <1288291138.2711.0.camel@edumazet-laptop>
References: <4CC99FDC.9070102@parallels.com>
	 <1288283634.11523.20.camel@edumazet-laptop>
	 <20101028.102917.246527148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63583 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761385Ab0J1SjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:39:04 -0400
Received: by wwe15 with SMTP id 15so2348592wwe.1
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:39:03 -0700 (PDT)
In-Reply-To: <20101028.102917.246527148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 octobre 2010 =C3=A0 10:29 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 28 Oct 2010 18:33:54 +0200
>=20
> > Le jeudi 28 octobre 2010 =C3=A0 20:07 +0400, Pavel Emelyanov a =C3=A9=
crit :
> >> commit e985aad7 (ip_gre: percpu stats accounting) forgot the fallb=
ack
> >> tunnel case (gre0).
> >>=20
> >> This is the 4th part of the "foo: fix percpu stats accounting" ser=
ies ;)
> >>=20
> >> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> >>=20
> >=20
> > Indeed, right you are ;)
> >=20
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied.


Hmm, actually patch is buggy, sorry...



