From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v2 00/16] wl1251 patches from linux-n900 tree
Date: Mon, 6 Jan 2014 15:00:50 -0500
Message-ID: <20140106200050.GG10885@tuxdriver.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <201312311047.30147@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luciano Coelho <luca@coelho.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	freemangordon@abv.bg, aaro.koskinen@iki.fi, pavel@ucw.cz,
	sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201312311047.30147@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 31, 2013 at 10:47:29AM +0100, Pali Roh=E1r wrote:
> On Sunday 08 December 2013 10:24:58 Pali Roh=E1r wrote:
> > Hello, I'm sending wl1251 patches from linux-n900 tree [1] for
> > comments. More patches come from David's monitor & packet
> > injection work. Patches are tested with 3.12 rc5 kernel on
> > Nokia N900.
> >=20
> > Second version contains new patch for fixing NULL pointer
> > dereference which sometimes cause kernel panic and fixes code
> > suggested by Pavel Machek.
=20
> So far, there are no new comments for patches 01, 03-13 and 16.=20
> Are there any other problems with that patches or can be accepted=20
> for upstream?
=20
They are probably fine to merge now.  Of course, I was still deleting
wl12xx patches when they were originally posted, so I'll need someone
to resend the patches to me...

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
