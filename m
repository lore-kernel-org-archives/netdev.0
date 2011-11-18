From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: routing bug?
Date: Fri, 18 Nov 2011 14:54:25 +0100
Message-ID: <1321624465.3277.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC648C9.8080405@uhulinux.hu>
			 <alpine.DEB.2.02.1111181346480.17023@aurora>
		 <1321621796.3277.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <4EC65C4B.6050505@uhulinux.hu>
	 <1321623207.3277.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EC65FF1.9010601@uhulinux.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Linux-Kernel-Mailinglist <linux-kernel@vger.kernel.org>,
	=?ISO-8859-1?Q?Tam=E1si_J=E1nos?= <janusz@uhulinux.hu>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Pozs=E1r_Bal=E1zs?= <pozsy@uhulinux.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EC65FF1.9010601@uhulinux.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 novembre 2011 =C3=A0 14:38 +0100, Pozs=C3=A1r Bal=C3=A1z=
s a =C3=A9crit :

> Unfortunately it does not solve the problem for me, I have have these=
=20
> "cache <redirected>" entries even after that echo command.
>=20

Its a problem with a cached value.

You must reboot to flush it.

It was already discussed yesterday on netdev.
