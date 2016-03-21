From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: AP firmware for TI wl1251 wifi chip (wl1251-fw-ap.bin)
Date: Mon, 21 Mar 2016 12:35:32 +0200
Message-ID: <878u1cglu3.fsf@kamboji.qca.qualcomm.com>
References: <201603200040.26045@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	kev-l0cyMroinI0@public.gmane.org, Shahar Levi <shahar_levi-l0cyMroinI0@public.gmane.org>,
	"Andrew F. Davis" <afd-l0cyMroinI0@public.gmane.org>, Guy Mishol <guym-l0cyMroinI0@public.gmane.org>,
	Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>, Arik Nemtsov <arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	Gery Kahn <geryk-l0cyMroinI0@public.gmane.org>, Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	David Gnedt <david.gnedt-KfBRzk3UKwrZI3uBz1zZ2F6hYfS7NtTn@public.gmane.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201603200040.26045@pali> ("Pali =?utf-8?Q?Roh=C3=A1r=22's?=
 message of "Sun, 20 Mar
	2016 00:40:25 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> In linux-firmware repository [1] is missing AP firmware for TI wl1251=
=20
> chip. There is only STA firmware wl1251-fw.bin which supports managed=
=20
> and ad-hoc modes.
>
> For other TI wilink chips there are <CHIP>-ap.bin firmware files=20
> (wl1271-fw-ap.bin and wl128x-fw-ap.bin) which support AP mode. But fo=
r=20
> wl1251 firmware file with guessed name "wl1251-fw-ap.bin" is missing.
>
> Do you have any idea what happened with AP firmware for ti wilink4=20
> wl1251 wifi chip? Or where can be found? Guys from TI, can you help?

It's a long time ago but IIRC wl1251 has not ever supported AP mode and
wl1271 was the first one to support it. But I might be wrong of course.

--=20
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
