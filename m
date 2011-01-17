From: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 15:01:32 +0100
Message-ID: <AANLkTi=6p_bzwRtP0dOyGXGJzMg=_dQg-593Zc9BYeu0@mail.gmail.com>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
 <1295261783.24530.3.camel@maggie> <AANLkTikJcug7LUTgX_YDD4Z8ZBrdkAdLq8_Epa6TkA5f@mail.gmail.com>
 <1295265468.24530.23.camel@maggie> <AANLkTims0DPfG+u9qynuuj_-0WjUr1nAGLuFz3k706T-@mail.gmail.com>
 <AANLkTinwGaqg8ahGWd3+_dfhrCNTQNOfO1E-EUepFJ+C@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTinwGaqg8ahGWd3+_dfhrCNTQNOfO1E-EUepFJ+C-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17 January 2011 14:54, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> wrote:
> If it's AMBA, can it be integrated with the existing code in drivers/amba/?

Hm, I once had a sentence about it there, I must have accidentally deleted it.

I tried finding similarities between Broadcom's code and ARM's AMBA
specification to better understand the code, but except some tiny ones
I couldn't find anything usable. Unfortunately I couldn't find
anything about Broadcom's AMBA implementation, except that it's "AMBA"
licensed from ARM.

Jonas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
