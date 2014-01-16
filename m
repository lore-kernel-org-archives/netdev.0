From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v2 00/16] wl1251 patches from linux-n900 tree
Date: Thu, 16 Jan 2014 15:29:45 -0500
Message-ID: <20140116202945.GD10165@tuxdriver.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <201312311047.30147@pali>
 <20140106200050.GG10885@tuxdriver.com>
 <20140116002121.GA3726@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org, joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140116002121.GA3726-tWAi6jLit6GreWDznjuHag@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 01:21:21AM +0100, Pavel Machek wrote:
> On Mon 2014-01-06 15:00:50, John W. Linville wrote:
> > On Tue, Dec 31, 2013 at 10:47:29AM +0100, Pali Roh=E1r wrote:
> > > On Sunday 08 December 2013 10:24:58 Pali Roh=E1r wrote:
> > > > Hello, I'm sending wl1251 patches from linux-n900 tree [1] for
> > > > comments. More patches come from David's monitor & packet
> > > > injection work. Patches are tested with 3.12 rc5 kernel on
> > > > Nokia N900.
> > > >=20
> > > > Second version contains new patch for fixing NULL pointer
> > > > dereference which sometimes cause kernel panic and fixes code
> > > > suggested by Pavel Machek.
> > =20
> > > So far, there are no new comments for patches 01, 03-13 and 16.=20
> > > Are there any other problems with that patches or can be accepted=
=20
> > > for upstream?
> > =20
> > They are probably fine to merge now.  Of course, I was still deleti=
ng
> > wl12xx patches when they were originally posted, so I'll need someo=
ne
> > to resend the patches to me...
>=20
> Ping? Did they get merged? Did you receive the patches?

They are already available in wireless-next.

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
