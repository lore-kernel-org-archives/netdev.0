From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v2 00/16] wl1251 patches from linux-n900 tree
Date: Mon, 6 Jan 2014 23:03:06 +0100
Message-ID: <20140106220306.GA24243@amd.pavel.ucw.cz>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
 <201312311047.30147@pali>
 <20140106200050.GG10885@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Luciano Coelho <luca@coelho.fi>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, sre@ring0.de, joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106200050.GG10885@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > Hello, I'm sending wl1251 patches from linux-n900 tree [1] for
> > > comments. More patches come from David's monitor & packet
> > > injection work. Patches are tested with 3.12 rc5 kernel on
> > > Nokia N900.
> > > 
> > > Second version contains new patch for fixing NULL pointer
> > > dereference which sometimes cause kernel panic and fixes code
> > > suggested by Pavel Machek.
>  
> > So far, there are no new comments for patches 01, 03-13 and 16. 
> > Are there any other problems with that patches or can be accepted 
> > for upstream?
>  
> They are probably fine to merge now.  Of course, I was still deleting
> wl12xx patches when they were originally posted, so I'll need someone
> to resend the patches to me...

I'll try to help with that (Pali has his development machine under
repairs), but I'll have to hunt it in archives, too...

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
