From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 0/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 18:59:43 +0100
Message-ID: <1291053583.3435.1269.camel@edumazet-laptop>
References: <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>
	 <1291043604.3435.969.camel@edumazet-laptop>
	 <20101129.093942.104054089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, tj@kernel.org,
	rusty@rustcorp.com.au, tony.luck@intel.com, fenghua.yu@intel.com
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20101129.093942.104054089.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 novembre 2010 =C3=A0 09:39 -0800, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 29 Nov 2010 16:13:23 +0100
>=20
> > Note : compiled and tested on x86_32 and x86_64 only, but these pat=
ches
> > take care of other arches as well.
> >=20
> > Cc: linux-arch@vger.kernel.org=20
> >=20
> > Thanks for your feedback Andi !
>=20
> I'm fine with these changes:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>
>=20
> Since the majority is non-networking it is pretty clear
> that someone other than me should integrate these patches.
> :-)

Sure !

I was thinking Andrew was the guy to carry this patch series, once
things settle down of course...

Thanks
