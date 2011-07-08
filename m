From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2011-07-08
Date: Fri, 08 Jul 2011 09:33:57 -0700 (PDT)
Message-ID: <20110708.093357.1592862635180925238.davem@davemloft.net>
References: <20110708162144.GA15143@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110708162144.GA15143-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Fri, 8 Jul 2011 12:21:44 -0400

> Here is a final(?) batch of wireless-related fixes intended for 3.0.
> Included are a fix for a TKIP replay vulnerability from Johannes, a
> locking fix related to rfkill and a memory corruption fix from Luca,
> an SSB initialization fix from Rafa=A9=A9, an ath9k performance regre=
ssion
> fix from Rajkumar, and some fixes from Pavel for sysfs bad pointer
> accesses in ath5k.
>=20
> Also included are some Bluetooth fixes.  Gustavo described them thusl=
y:
>=20
> 	There are here two regression fixes, a hidp deadlock hang up
> 	of the system fix from Peter Hurley. As the commit messages
> 	says it is a partial revert from a commit that adds kthread
> 	to hidp. And L2CAP incoming connection request fix that
> 	was breaking one test in the PTS suit, that is, breaking
> 	interop. Patch is based on code from Ilia Kolomisnky.  Also,
> 	a buffer overflow fix by Dan Rosenberg and finally Tomas
> 	Targownik fixed a memory leak on failed connections attempts
> 	that seems to be around since 2006!!
>=20
> I also included a couple of device ID additions -- I hope that's OK.
>=20
> Please let me know if there are problems!

Pulled, thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
