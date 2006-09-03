From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Accept -1 for IPV6_TCLASS
Date: Sun, 03 Sep 2006 19:07:54 +0900 (JST)
Message-ID: <20060903.190754.58350618.yoshfuji@linux-ipv6.org>
References: <200609031028.31236@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32271 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751173AbWICKF6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 06:05:58 -0400
To: davem@davemloft.net, rdenis@simphalempin.com
In-Reply-To: <200609031028.31236@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200609031028.31236@auguste.remlab.net> (at Sun, 3 Sep 2006 =
10:28:30 +0300), R=E9mi Denis-Courmont <rdenis@simphalempin.com> says:

> This patch should add support for -1 as "default" IPv6 traffic class,=
 as=20
> specified in IETF RFC3542 =A76.5. Within the kernel, it seems tclass =
< 0=20
> is already handled, but setsockopt, getsockopt and recvmsg calls won'=
t=20
> accept it from userland.
>=20
> Signed-off-by: Remi Denis-Courmont <rdenis@simphalempin.com>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

--=20
VGER BF report: S 1
