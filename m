From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Tue, 01 Mar 2011 21:16:27 +0100
Message-ID: <1299010587.2930.2.camel@edumazet-laptop>
References: <20110228165501.GC2515@tuxdriver.com>
	 <AANLkTinj5szpStmA+fZ1xggdyTS+sd8Y9jXaYquDNEjs@mail.gmail.com>
	 <AANLkTinFZu5AgfhO6PoA7C1NTGSfD8HH0KXq_o-mHEJF@mail.gmail.com>
	 <20110228.201852.193726064.davem@davemloft.net>
	 <AANLkTi=eDQh9Kvr9N_dTC5Cnbcfb+DbO-6tLxkZiEp9v@mail.gmail.com>
	 <1298964381.2676.58.camel@edumazet-laptop>
	 <AANLkTimWMZHVQSHEUPuQgFXxNg85dEOesqhZE=e6x8kb@mail.gmail.com>
	 <1299010479.2930.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, johnwheffner@gmail.com,
	linville@tuxdriver.com, jussi.kivilinna@mbnet.fi, swmike@swm.pp.se,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299010479.2930.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 mars 2011 =C3=A0 21:14 +0100, Eric Dumazet a =C3=A9crit :
> Le mardi 01 mars 2011 =C3=A0 14:37 -0500, Albert Cahalan a =C3=A9crit=
 :
> >=20
> > We certainly should allow some traffic spikes. 1 to 10 ms of
> > traffic ought to do nicely. Hundreds or thousands of ms is
> > getting way beyond "spike".
>=20
> OK.

Hmm, user error, hit wrong button, sorry.
