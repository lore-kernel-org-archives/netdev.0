From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Tue, 12 Apr 2011 16:49:42 -0400
Message-ID: <20110412204941.GD24309@tuxdriver.com>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com>
 <1302084582.3811.9.camel@jlt3.sipsolutions.net>
 <4D9C43A8.5060500@redhat.com>
 <20110406125728.GA2197@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Meenakshi Venkataraman <meenakshi.venkataraman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406125728.GA2197-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2011 at 02:57:29PM +0200, Stanislaw Gruszka wrote:
> On Wed, Apr 06, 2011 at 06:42:48PM +0800, Cong Wang wrote:
> > =E4=BA=8E 2011=E5=B9=B404=E6=9C=8806=E6=97=A5 18:09, Johannes Berg =
=E5=86=99=E9=81=93:
> > >On Wed, 2011-04-06 at 17:49 +0800, Amerigo Wang wrote:
> > >>As scheduled in Documentation/feature-removal-schedule.txt,
> > >>remove "*50", "disable_hw_scan" module parameters and MODULE_ALIA=
S("iwl4965").
> > >
> > >Mostly fine, but for iwlegacy Stanislaw we want to keep hw scan (a=
nd it
> > >was actually made default now)
>=20
> Indeed, disable_hw_scan should be removed in iwlwifi but leaved in iw=
legacy.
>=20
> > Ok, I will wait for Stanislaw's response and then send an updated p=
atch.
>=20
> Have it now :-)

Ping?

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
