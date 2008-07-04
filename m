From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 00/39]: New multiqueue TX implementation.
Date: Fri, 04 Jul 2008 17:33:48 +0800
Message-ID: <E1KEhfo-0001RJ-00@gondolin.me.apana.org.au>
References: <20080703.000146.168093325.davem@davemloft.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-xsfywfwIY+M@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org (David Miller)
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080703.000146.168093325.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> 
> I'm finally at the point where I can post a patch series that actually
> does something and I know works for at least one card :-)
> 
> The backlog and batching bits are sidelined for the time being.
> Don't worry, we'll get back to that soon enough :)
> 
> This can all be found in:
> 
>        kernel.org:/pub/scm/linux/kernel/git/davem/net-tx-2.6.git
> 
> which uses net-next-2.6 as it's origin.

I've only had a quick look but it is clear that this stuff is
pretty awesome and fills in a major missing piece of infrastructure
that's needed to bring Linux networking into the age of multi-core.

Nice work!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
