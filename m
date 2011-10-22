From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] bonding : LOCKDEP warning
Date: Sat, 22 Oct 2011 11:19:47 +0200
Message-ID: <1319275187.6180.25.camel@edumazet-laptop>
References: <1319268987.6180.21.camel@edumazet-laptop>
	 <m14nz1l8mc.fsf@fess.ebiederm.org>
	 <1319274349.6180.23.camel@edumazet-laptop>
	 <20111022.050914.551507702374659667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52863 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab1JVJT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 05:19:56 -0400
Received: by wyg36 with SMTP id 36so4699870wyg.19
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2011 02:19:55 -0700 (PDT)
In-Reply-To: <20111022.050914.551507702374659667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 octobre 2011 =C3=A0 05:09 -0400, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 22 Oct 2011 11:05:49 +0200
>=20
> > Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Patchwork says "parse error"
>=20
> I'll fix it up this time, but please do not use free form
> tags like this in the future.  Thanks.

Strange, it seems quite usual these days, you're the first one to
complain. Maybe compain to Patchwork ?

    Reported-and-tested-by: Shlomo Pongratz <shlomop@mellanox.com>
    Reported-and-tested-by: Simon Kirby <sim@hostway.ca>
    Reported-and-tested-by: Amir Vadai <amirv@dev.mellanox.co.il>
    Reported-and-tested-by: Alexandre Oliva <aoliva@redhat.com>
    Reported-and-tested-by: Rocko Requin <rockorequin@hotmail.com>
    Reported-and-tested-by: Richard Cochran <richardcochran@gmail.com>
    Reported-and-tested-by: Guennadi Liakhovetski <g.liakhovetski@gmx.d=
e>
    Reported-and-tested-by: Hor Jiun Shyong <jiunshyong@gmail.com>
    Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
    Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>
    Reported-and-tested-by: Niels Ole Salscheider <niels_ole@salscheide=
r-online.de>
    Reported-and-tested-by: Jan Teichmann <jan.teichmann@gmail.com>
    Reported-and-tested-by: Arnaud Lacombe <lacombar@gmail.com>
    Reported-and-tested-by: Jim Bray <jimsantelmo@gmail.com>
    Reported-and-tested-by: Muhammad Khurram Khan
    Reported-and-tested-by: Matej Laitl <matej@laitl.cz>
    Reported-and-tested-by: Thomas Seilund <tps@netmaster.dk>
    Reported-and-tested-by: Ren=C3=A9 Fritz <rene@colorcube.de>
    Reported-and-tested-by: Randy Dunlap <rdunlap@xenotime.net>
    Reported-and-tested-by: William Light <wrl@illest.net>
    Reported-and-tested-by: Xiaotian Feng <xtfeng@gmail.com>
    Reported-and-tested-by: Dave Jones <davej@redhat.com>
    Reported-and-tested-by: Xiaotian Feng <xtfeng@gmail.com>
    Reported-and-tested-by: Joachim Eastwood <manabian@gmail.com>
    Reported-and-tested-by: Pavel Roskin <proski@gnu.org>
    Reported-and-tested-by: Christian Casteyde <casteyde.christian@free=
=2Efr>
    Reported-and-tested-by: Sebastian Siewior <sebastian@breakpoint.cc>
=2E..
