From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge/netfilter: regression in 2.6.39.1
Date: Fri, 03 Jun 2011 21:55:14 +0200
Message-ID: <1307130914.2600.12.camel@edumazet-laptop>
References: <4DE93422.3070000@ahsoftware.de>
	 <1307129642.2600.2.camel@edumazet-laptop>  <4DE93B31.8040700@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE93B31.8040700@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 03 juin 2011 =C3=A0 21:51 +0200, Alexander Holler a =C3=A9c=
rit :
> Hello,
>=20
> Am 03.06.2011 21:34, schrieb Eric Dumazet:
> >>
> >> Commit 42923465fb8d025a2b5153f2e7ab1e6e1058bf00 does here what it
> >> should prevent, it introduces NULL a dereference.
> >>
> >
> > I cant find this commit in known trees. Could you give the real com=
mit
> > id and its title ?
>=20
> Sorry, I haven't seen that question at first. This is the real commit=
 id=20
> as found in the stable tree for 2.6.39. The title of that commit is
> "bridge: initialize fake_rtable metrics"

OK, its commit id is 33eb9873a283a2076f2b5628813d5365ca420ea9

Please always use linux-2.6 tree commits, this saves a lot of time.

Thanks
