From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
Date: Thu, 16 Feb 2012 07:18:02 +0100
Message-ID: <1329373082.5646.9.camel@edumazet-laptop>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
	 <C6B7BB6C-D1B8-4454-A2B2-558FCA5B0BBD@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>, Josh Boyer <jwboyer@gmail.com>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C6B7BB6C-D1B8-4454-A2B2-558FCA5B0BBD@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 07:13 +0100, Thomas Meyer a =C3=A9=
crit :

> Hello Eric,
>=20
> >=20
> > Thomas, have you had the chance to test this patch ?
>=20
> Yes, I'm running 3.2.6 with your patch applied for 3 days now. I didn=
't see above warning yet, but the warning was rather seldom, so I'll ke=
ep an eye on it in the next weeks.
>=20
> Thanks for the patch!
>=20

Thanks for testing !

Do have any idea of what could set skb mark to 1 on some packets on you=
r
setup ?

Some firewall rules or tc rules ?
