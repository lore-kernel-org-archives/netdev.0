From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-07-27
Date: Wed, 27 Jul 2011 22:22:47 -0700 (PDT)
Message-ID: <20110727.222247.2000159983502866405.davem@davemloft.net>
References: <20110727184920.GB16431@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110727184920.GB16431-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 27 Jul 2011 14:49:21 -0400

> Here is a handful of fixes intended for 3.1.  This includes a
> user-visible typo fix, a fix for a user after free in the new pn533
> NFC driver, a cfg80211 fix for a possible NULL pointer dereference,
> a fix for an invalid memory access in b43, and another b43 fix for
> a memory corruption problem.
>=20
> On top of that b43 memory corruption fix, there is a patch to remove
> BROKEN from the B43_BCMA Kconfig entry, which is key to enabling
> support for some of the more modern Broadcom wireless hardware.
> I'm sure the Rafa=A9=A9 (and a number of others) would love to see th=
at
> merged while the 3.1 merge window is still open as well.
>=20
> Please let me know if there are problems...

Yep, removing BROKEN from b43 seems reasonable.

Pulled, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
