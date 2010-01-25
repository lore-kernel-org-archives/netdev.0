From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems Receiving UDP Broadcasts on Some Versions of Linux
Date: Mon, 25 Jan 2010 09:10:14 +0100
Message-ID: <4B5D51E6.5090601@gmail.com>
References: <20100125072749.GG21419@analytic.cynic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Curt Sampson <cjs@starling-software.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752477Ab0AYIKj@vger.kernel.org>
In-Reply-To: <20100125072749.GG21419@analytic.cynic.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 25/01/2010 08:27, Curt Sampson a =E9crit :
> I'm posting this here because it smells as if it may be something
> a where a kernel network code developer might just say, "oh yeah,
> obviously your problem is this."
>=20
> I'm not subscribed to this list, so please cc me on any replies. (The
> Mail-followup-to header may do this automatically for you.)
>=20
> The short summary is that on two very similar servers on the same
> network, an application that listens for broadcast UDP packets on a
> given port works fine on the Ubuntu 8.04/Linux 2.6.24-26-server box b=
ut
> does not receive the packets on the Ubuntu 9.04/Linux 2.6.28-17-serve=
r
> box. I have confirmed that tcpdump sees identical packets being recei=
ved
> on both hosts.
>=20
> Did something change between these two kernel revisions that I need t=
o
> listen differently?
>=20
> Full details, including sample code, are available at:
>=20
>   http://stackoverflow.com/questions/2130563/udp-broadcast-reception-=
problems-with-ubuntu-9-04-but-not-8-04
>=20
> Thanks for any help you can give me. Even if you're not sure, but hav=
e
> clues I should consider following up, feel free to e-mail me. I'm
> also happy to take pointers to kernel code I should read, if there's
> enlightenment there.
>=20
> cjs

Hi Curt

Could you post a sample of tcpdump trafic you receive on the 9.04 host,=
 and your network config ?
"ifconfig -a"
