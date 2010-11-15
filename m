From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2010-11-15
Date: Mon, 15 Nov 2010 22:55:55 +0100
Message-ID: <AANLkTikZyvZ+vNti_9FTg3JgAC19QFkXDX4nTvaA-YaX@mail.gmail.com>
References: <20101115212520.GD2297@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101115212520.GD2297-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2010/11/15 John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>:
> Here is the traditional first huge pull request intended for the 2.6.=
38!
>
> Included are the usual batch of updates to various wireless drivers.
> For good measure, Luis also gives us a few wireless regulatory contro=
l
> patches as well.
>
> Please let me know if there are problems!

Nothing that should postpone this pull, but could you check for
following patches?
[PATCH] ssb: workarounds: be verbose about hacking SPROM revision,
don't duplicate code
[PATCH] ssb: return -ENOMEM on alloc fail (instead of CRC check's resul=
t)
[PATCH] ssb: fail registration for unknown SPROM revision

It looks like you missed them. All 3 were sent on 3.11.2010

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
