From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 12:56:25 -0800
Message-ID: <CAG4TOxOq0Aj+zt_6s4ebmZP1v3COYpozm7mmaSBHF=1yVaJ8Lw@mail.gmail.com>
References: <alpine.WNT.2.00.1111291027320.1036@TSI> <1322589661.2596.2.camel@edumazet-laptop>
 <1322599437.2596.10.camel@edumazet-laptop> <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
 <1322599991.2596.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322599991.2596.11.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

OK, haven't sent it on yet :)

On Tue, Nov 29, 2011 at 12:53 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
> Le mardi 29 novembre 2011 =E0 12:47 -0800, Roland Dreier a =E9crit :
>> Thanks Eric, I'll send this to Linus shortly.
>
> Oh well, I forgot one rcu_read_unlock(), I'll send a V2...
>
>
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
