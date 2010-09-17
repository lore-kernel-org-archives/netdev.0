From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the rcu tree
Date: Fri, 17 Sep 2010 07:34:26 +0200
Message-ID: <1284701666.4784.36.camel@edumazet-laptop>
References: <20100917124238.aa0596cb.sfr@canb.auug.org.au>
	 <20100916.213939.24608537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, paulmck@linux.vnet.ibm.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100916.213939.24608537.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 septembre 2010 =C3=A0 21:39 -0700, David Miller a =C3=A9cri=
t :
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 17 Sep 2010 12:42:38 +1000
>=20
> > Subject: [PATCH] net: include inetdevice.h for rcu_dereference_raw =
api change
> >=20
> > rcu_dereference_raw() now needs to know the type of its argument.
> >=20
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> I've tossed this into net-next-2.6, thanks!

Thanks guys
