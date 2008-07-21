From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Mon, 21 Jul 2008 07:39:31 -0400
Message-ID: <1216640371.4847.230.camel@localhost>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au>
	 <1216568119.4847.101.camel@localhost>
	 <20080721001119.GA6515@gondor.apana.org.au>
	 <1216607637.4847.172.camel@localhost>
	 <20080721031716.GA7535@gondor.apana.org.au>
	 <1216638879.4847.210.camel@localhost>
	 <20080721113600.GA10322@gondor.apana.org.au>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721113600.GA10322-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-21-07 at 19:36 +0800, Herbert Xu wrote:

> Sorry, I think I'll have to poke my eyes out :)

But i still need your eyes to poke at my code Herbert;-> 

> But yeah if we ever get a generic dynamic hash table implmenetation
> then I'd be happy for act_nat to use that.

Ok, i have added it to my todo.

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
