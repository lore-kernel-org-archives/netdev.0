From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [3.1] Divide by zero in __tcp_select_window()
Date: Wed, 16 Nov 2011 21:26:37 +0100
Message-ID: <1321475197.3274.0.camel@edumazet-laptop>
References: <20111108205411.GA23642@hostway.ca>
	 <1320787405.26025.10.camel@edumazet-laptop>
	 <20111114.153608.2064552703690099046.davem@davemloft.net>
	 <1321304216.2719.23.camel@edumazet-laptop>
	 <20111116195419.GE24411@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	schwidefsky@de.ibm.com, mingo@elte.hu
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111116195419.GE24411@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 novembre 2011 =C3=A0 11:54 -0800, Simon Kirby a =C3=A9cr=
it :

> Looks good, thanks! Working on ~25 boxes without issue for >36 hours.
>=20
> Simon-
>=20
> Tested-by: Simon Kirby <sim@hostway.ca>

Thanks Simon for this feedback.
