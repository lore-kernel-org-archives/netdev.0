From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [announce] new rt2800 drivers for Ralink wireless & project
	tree
Date: Fri, 6 Nov 2009 08:46:44 +0100
Message-ID: <20091106074643.GA5562@ucw.cz>
References: <200911031951.05235.bzolnier@gmail.com> <200911032200.04516.IvDoorn@gmail.com> <20091104083737.GA16978@elte.hu> <200911042251.23506.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>,
	Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200911042251.23506.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> > Look at the diffstat of Bart's driver:
> > 
> >    15 files changed, 4036 insertions(+), 7158 deletions(-)
> > 
> > He reduced your 5.2 KLOC non-working driver into a 1.8 KLOC _working_ 
> > driver.
> 
> Bullshit, read the mails again.

This was uncalled for, right?

...
> Some people actually require sleep during the night, perhaps that you don't need
> that and can hence review 41 patches which changes thousands of lines on the
> same day the patches were submitted.

If you lack time, "Really start reading my mails" sentence you used at
the start of email is *not* user-friendly way to say that.

> > And _still_ your complaint about Bart's series is that he updated the 
> > MAINTAINERS entry and added an entry for rt2800? Heck _sure_ he should 
> > update it, he is the one doing the hard work of trying to bring it to 
> > users, trying to clean up a messy driver space, trying to turn crap into 
> > gold.
> 
> So if I want to focus on something different in the kernel, I just send 1 patch,
> and a second to claim the maintainership of it even though there is an active
> maintainer available?

What about listing yourself as a maintainer for a start?

> > The thing is, if you dont have the time or interest to listen to and act 
> > upon review feedback, be constructive about it and fix (obvious) 
> > structural problems in your rt2800 code, you should just step aside and 
> > let Bart maintain what he is apparently more capable of maintaining than 
> > you are.
> >
> > What you are doing here is a thinly veiled land-grab: you did a minimal 
> > token driver for rt2800 that doesnt work, kept it in your private tree 
> > for _1.5 years_, and the moment someone _else_ came along and did 
> > something better and more functional in drivers/staging/, you discovered 
> > your sudden interest for it and moved the crappy driver upstream at 
> > lightning's speed (it is already in net-next AFAICS, despite negative 
> > test and review feedback) - ignoring and throwing away all the work that 
> > Bart has done.
> 
> Get your facts straight, the bullshit level in your mail is staggering.
> 
> You have no fucking clue who wrote the rt2800 driver which is in
> drivers/staging/,

Perhaps you should not be a maintainer if you can't behave yourself?

> 	Because a lot of people prefer looking from the sideline,
> contributing _nothing_

Given your behaviour, I'm not suprised people are not too eager to
work with you.

> As for "throwing away that work" I ACKED 10 of his patches, and said I would review
> the rest later! But like I said, apparently it is a bad habit for people to sleep during
> the night.

Read your email again. It was quite far from 'acked 10, asked for
time'. You flamed him first.
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
