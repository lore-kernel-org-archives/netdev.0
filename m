From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the suspend tree
Date: Fri, 21 May 2010 07:51:57 +0200
Message-ID: <1274421117.4977.9.camel@edumazet-laptop>
References: <20100507130821.3fb72c9d.sfr@canb.auug.org.au>
	 <201005080413.24465.rjw@sisk.pl>
	 <20100521102913.ae4e8cd2.sfr@canb.auug.org.au>
	 <20100520.224644.21290162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, linville@tuxdriver.com,
	torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Helmut.Schaa@gmx.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100520.224644.21290162.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 mai 2010 =C3=A0 22:46 -0700, David Miller a =C3=A9crit :
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 21 May 2010 10:29:13 +1000
>=20
> > On Sat, 8 May 2010 04:13:24 +0200 "Rafael J. Wysocki" <rjw@sisk.pl>=
 wrote:
> >>
> >> On Friday 07 May 2010, Stephen Rothwell wrote:
> >> Both trees are based on Linus' current and I don't see a good way =
of fixing
> >> this issue in any of them individually.
> >=20
> > The suspend tree has been merged into Linus' tree, so this patch is
> > needed in the net tree before it is merged (or as part of the merge=
).
>=20
> Since the net tree is still on it's way to Linus, we'll just have to
> wait for him to do that merge.
>=20
> Then we can sort this out.  I don't want to touch a tree that is
> already on it's way.

Linus merged your tree David.
