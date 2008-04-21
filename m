From: "Ron Rindjunsky" <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [2.6 patch] make sta_rx_agg_session_timer_expired() static
Date: Mon, 21 Apr 2008 17:53:29 +0300
Message-ID: <c85cb4470804210753q394962f9lcd03d6c4beed077f@mail.gmail.com>
References: <20080421084751.GI26897@cs181133002.pp.htv.fi>
	 <1208769228.26186.58.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Tomas Winkler" <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1208769228.26186.58.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Mon, 2008-04-21 at 11:47 +0300, Adrian Bunk wrote:
> > sta_rx_agg_session_timer_expired() can now become static.
> >
> > Signed-off-by: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>
> Good plan, thanks.
>
> johannes

Agree, thanks

Ron
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
