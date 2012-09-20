From: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 2/2] Using LP firmware for taking advantage of the
 low-power capabilities.
Date: Thu, 20 Sep 2012 08:32:42 +0200
Message-ID: <CAOjsGA3cmuGHY1WAJ92RwbUf1iNpFHaSvePxvzSYxkY1FJzjkw@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk>
 <1348053493-22955-2-git-send-email-jarl@softace.dk> <CAOjsGA2uvCxnX1PH85w2vO894kZT+af-Tgj7bV-3kw3ScxN10g@mail.gmail.com>
 <CACna6ryRXB6GjymaP-RM8HTEeWRHnE8B=5tdH3J4JGyeHBEE6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	=?UTF-8?Q?G=C3=A1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACna6ryRXB6GjymaP-RM8HTEeWRHnE8B=5tdH3J4JGyeHBEE6Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2012/9/20 Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> Well, your BCM4322 is not LP-PHY card... does it really work better
> after that change, and wakes up faster? ;)

That was my un-scientific impression, yes (probably biased by
expectations, right? :-) ). But it could also be that I was using a
more upstream kernel than the stock ubuntu kernel. I don't know :-)

> BCM4313 is LCN-PHY, so your change won't affect it, not to mention it
> is not supported by b43.
>
> 14e4:4315 is really BCM4312 (LP-PHY) and maybe could be affected by
> this patch... but just in case of core 16. AFAIK our 14e4:4315 are
> usually devices with core rev 15.

Thanks for clearing that out...

Jarl
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
