From: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Subject: Re: rt2x00: Kconfig symbols RALINK_RT288X and RALINK_RT305X
Date: Wed, 13 Mar 2013 11:03:59 +0100
Message-ID: <1363169039.3137.186.camel@x61.thuisdomein>
References: <1363165170.3137.182.camel@x61.thuisdomein>
	 <CAOiHx=n4a26z=PS02E2KjD2Y3Pp0P0x-5Ns6WRc-WScNF=EO_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Crispin <blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Jonas Gorski <jogo-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAOiHx=n4a26z=PS02E2KjD2Y3Pp0P0x-5Ns6WRc-WScNF=EO_Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-03-13 at 10:51 +0100, Jonas Gorski wrote:
> On 13 March 2013 09:59, Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org> wrote:
> > 3) What is the current status of the (out of tree) code that adds
> > RALINK_RT288X and RALINK_RT305X?
> 
> They are now present in 3.9-rc1, see a0b0197c (more specifically
> 85639910..d3d2b420) :)

Great.

> The actual accepted Kconfig symbol names are different though, so they
> should be changed in rt2x00 to match them (SOC_RT288X and SOC_RT305X).

Thanks. Note that I could not find an actual Kconfig symbol SOC_RT288X! 

Anyhow, I guess somebody has the (trivial) patch to convert
RALINK_RT...X and CONFIG_RALINK_RT...X to their SOC_* equivalents queued
for inclusion in v3.9-rcX. Is that correct?


Paul Bolle

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
