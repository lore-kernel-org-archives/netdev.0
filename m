From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-07-24
Date: Sun, 26 Jul 2009 13:52:57 -0400
Message-ID: <20090726175257.GA5630@tuxdriver.com>
References: <20090724193625.GB2711@tuxdriver.com> <20090726.100214.125172881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090726.100214.125172881.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 26, 2009 at 10:02:14AM -0700, David Miller wrote:
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Fri, 24 Jul 2009 15:36:25 -0400
>=20
> > Here is the latest huge round of wireless patches intended for 2.6.=
32.
> > It hits all the usual areas (i.e. drivers, mac80211, and cfg80211) =
with
> > patches from all the usual suspects.  This includes the reworking o=
f
> > mac80211 to eliminate the confusing "master netdev".
> >=20
> > FWIW, my laptop has been happy with it.  Most of the bits here have=
 been
> > in -next for at least a few days.
> >=20
> > Please let me know if there are problems!
>=20
> Pulled, thanks a lot John!
>=20
> Please try to resolve the regression reports that I saw posted agains=
t
> wireless-testing on the same day you sent this pull request.

Certainly!  But FWIW I think most of those are about patches that I
have not yet sent to you, so I don't think you need to worry a lot
about your tree ATM.

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
			=A1Viva Honduras Libre!
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
