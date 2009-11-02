From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Mon, 2 Nov 2009 13:29:53 -0500
Message-ID: <20091102182953.GH14046@tuxdriver.com>
References: <1256886023.3555.5.camel@johannes.local> <20091030110616.GB6150@ff.dom.local> <20091030150223.GA2586@tuxdriver.com> <20091102091038.GA9044@elte.hu> <1257153807.3555.173.camel@johannes.local> <20091102100702.GA16963@elte.hu> <20091102170114.GE14046@tuxdriver.com> <efe7343f0911020932l21a570c8u9478568329d38e2c@mail.gmail.com> <4AEF1894.2010809@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AEF1894.2010809-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2009 at 09:36:20AM -0800, Randy Dunlap wrote:
> Luis Correia wrote:
> > [huge snip]
> > 
> > This is going to be my last reply to this thread (even if I get to be insulted).
> > 
> > I'm not a coder, I'm a tester and administrator for the rt2x00 project.
> > I'm not happy about the current state of the rt2x00 in-kernel drivers.
> > I tend to agree that more could be done.
> > 
> > Even though I'm not a coder, I could be hipotetically responsable for
> > the current situation. It is my job function to motivate people to
> > work on the rt2x00 in-kernel drivers, but apparently I've failed here.
> > It's not an atitude problem, as some have suggested, it's just life.
> > 
> > About Bartlomiej, there is only one more thing that I'll say:
> > 
> > I've searched on my GMail archives and the only patch Bart has
> > provided so far for the rt2x00 project is this:
> > 
> > [PATCH] MAINTAINERS: rt2x00 list is moderated
> > 
> > Which, while technically correct, adds nothing to the project.
> 
> whatever.  That patch still needs to be applied.

And, in fact, it has been...already in linux-2.6:

	commit b5654f5e7fc414a6e69b3647db2b043257c9e62e
	Author: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
	Date:   Mon Oct 26 16:49:50 2009 -0700

	MAINTAINERS: rt2x00 list is moderated

	Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
	Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
	Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>

Hth...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
