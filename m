From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 03 May 2010 07:43:56 +0200
Message-ID: <1272865436.2173.182.camel@edumazet-laptop>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
	 <5702.1272822394@localhost>  <1272865137.2173.179.camel@edumazet-laptop>
	 <1272865267.2173.180.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272865267.2173.180.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 mai 2010 =C3=A0 07:41 +0200, Eric Dumazet a =C3=A9crit :

> Oops scratch that, I'll resend a correct version.
>=20
>=20

Sorry, patch _is_ fine, I had one brain collapse when re-reading it, I
thought a different mutex was in use in one of the functions.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
