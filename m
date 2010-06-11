From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
	support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Fri, 11 Jun 2010 13:07:42 -0400
Message-ID: <AANLkTimUW58T19GOkRk3oCC9huLDQLgLj4W3RjiQ9n53@mail.gmail.com>
References: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
	<AANLkTilrYYHjcMEhhrP7zjcLoo-TNczozxJSNRkDvSZy@mail.gmail.com>
	<AANLkTimXqdkQxv_Y1JaleTTWNsDIQHQaPn8HR7efOupb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	GeunSik Lim <geunsik.lim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Keng-Yu Lin <keng-yu.lin-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Shahar Or <shahar-ThuA2tnqEQ612v9G2T7xgg@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Luca Verdesca <magooz-JapBdFJSX0s@public.gmane.org>
To: Dmytro Milinevskyy <milinevskyy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimXqdkQxv_Y1JaleTTWNsDIQHQaPn8HR7efOupb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 9, 2010 at 10:43 AM, Dmytro Milinevskyy
<milinevskyy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi, Bob.
>
> For instance I don't use 802.11 leds layer and trigger leds from
> userspace according to my purposes.

FWIW you can disable mac80211 triggers from userspace as well.
But, I guess hooking up null triggers will work too.

-- 
Bob Copeland %% www.bobcopeland.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
