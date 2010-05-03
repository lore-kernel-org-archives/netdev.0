From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 13:24:42 -0700 (PDT)
Message-ID: <20100503.132442.200112018.davem@davemloft.net>
References: <1272916007.2407.75.camel@edumazet-laptop>
	<20100503.130902.172620141.davem@davemloft.net>
	<1272917635.2407.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272917635.2407.106.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 May 2010 22:13:55 +0200

> Le lundi 03 mai 2010 =E0 13:09 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 03 May 2010 21:46:47 +0200
>>=20
>> > Then, net-next-2.6 doesnt yet have your commit Paul to relax
>> > hlist_for_each_entry_rcu(), so its a bit difficult to continue the=
 work.
>>=20
>> Is that in Linus's tree yet?  If it propagates there I can make it
>> propagate to net-next-2.6, you just have to tell me you need it.
>=20
>=20
> Hmm, it seems it's already in net-next-2.6, sorry for the confusion.

No problem, just let me know in the future if something upstream needs
to propagate.
