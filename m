From: Lukasz Trabinski <lukasz@trabinski.net>
Subject: Re: unregister_netdevice 2.6.9
Date: Fri, 22 Oct 2004 13:56:01 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58LT.0410221351580.2616@lt.wsisiz.edu.pl>
References: <Pine.LNX.4.58LT.0410191738420.2725@lt.wsisiz.edu.pl>
 <20041020.154045.128392519.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041020.154045.128392519.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004, YOSHIFUJI Hideaki / ???? wrote:

> > After shutdown/reboot :
> >=20
> > unregister_netdevice: waiting for xxxx to become free. Usage count =3D=
 1
> >=20
> > and still wait.
>=20
> Does this fix your problem?

I have just applied this patch, but i have still problem with=20
unregister_netdevice.

--=20
=A3T
