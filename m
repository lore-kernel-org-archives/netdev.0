From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] networking: [IPv6] Don't generate temporary for TUN
 devices
Date: Sat, 11 Jun 2005 22:32:57 +0900 (JST)
Message-ID: <20050611.223257.46118215.yoshfuji@linux-ipv6.org>
References: <200506111512.42592.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rdenis@simphalempin.com, davem@davemloft.net
In-Reply-To: <200506111512.42592.rdenis@simphalempin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200506111512.42592.rdenis@simphalempin.com> (at Sat, 11 Jun 2=
005 15:12:40 +0200), R=E9mi Denis-Courmont <rdenis@simphalempin.com> says=
:

> Dec 29 11:02:04 auguste kernel: __ipv6_regen_rndid(idev=3Dcb3e0c00):=20
> cannot get EUI64 identifier; use random bytes.
:
> As far as I could fine, TUN virtual device from TUNTAP is the very only=
=20
> sort of device using ARPHRD_NONE as kernel device type.

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
