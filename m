From: "Andre Tomt" <andre@tomt.net>
Subject: RE: unable to add ipv6 default route in 2.4.21-rc1 + latest bkbits.net pieces
Date: Fri, 2 May 2003 23:38:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <009301c310f3$319bd760$0a01ff0a@slurv>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replying to myself here.

<snip>
> 2001:730:f:3::/64 dev eth0  proto kernel  metric 256  mtu=20
> 1500 advmss 1440 fe80::/64 dev eth0  proto kernel  metric 256=20
>  mtu 1500 advmss 1440 ff00::/8 dev eth0  proto kernel  metric=20
> 256  mtu 1500 advmss 1440 unreachable default dev lo  proto=20
> none  metric -1  error -101

Oops, this was'nt supposed to be pasted here.

> kvass:~# ip -6 route
> 2001:730:f:3::/64 dev eth0  proto kernel  metric 256  mtu=20
> 1500 advmss 1440 fe80::/64 dev eth0  proto kernel  metric 256=20
>  mtu 1500 advmss 1440 ff00::/8 dev eth0  proto kernel  metric=20
> 256  mtu 1500 advmss 1440 default dev eth0  proto kernel =20
> metric 256  mtu 1500 advmss 1440 unreachable default dev lo =20
> proto none  metric -1  error -101

This however, is still the right one. :-)

--=20
Cheers,
Andr=E9 Tomt
andre@tomt.net
