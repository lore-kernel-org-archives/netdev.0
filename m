From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 kernel ooops
Date: Sun, 25 Apr 2004 10:54:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040425.105411.127614608.yoshfuji@linux-ipv6.org>
References: <20040424222340.GA10595@binhex.EU.org>
	<20040425.104217.31070133.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gdh@binhex.EU.org
In-Reply-To: <20040425.104217.31070133.yoshfuji@wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040425.104217.31070133.yoshfuji@wide.ad.jp> (at Sun, 25 Apr=
 2004 10:42:17 +0900 (JST)), YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E <yoshfuji@wide.ad.jp> says:

> In article <20040424222340.GA10595@binhex.EU.org> (at Sat, 24 Apr 2004 =
22:23:41 +0000), Gu=C3=B0mundur D. Haraldsson <gdh@binhex.EU.org> says:
>=20
> > I got this oops on my machine tonight.
> >
> > I don't know what query to BIND caused it, but I've got an oops like =
this before!
>=20
> Is this reproducable? How frequently do you see this?

Oh, sorry, I looked into 2.6.x.
I've found it at net/ipv4/ip_output.c in 2.4.x.
I haven't seen that oops before, as far as I can recall.
Please try latest vanilla kernel (2.4.26 or so).
Thanks.

--yoshfuji
