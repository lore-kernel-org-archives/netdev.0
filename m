From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC][WIP] IEEE 802.15.4 implementation for Linux v1
Date: Sun, 21 Jun 2009 08:40:19 +0200
Message-ID: <20090621064018.GB1656@ucw.cz>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com> <9e4733910906122021k4568df6rd80fb915b64ac12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Jon Smirl <jonsmirl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9e4733910906122021k4568df6rd80fb915b64ac12-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri 2009-06-12 23:21:34, Jon Smirl wrote:
> On Mon, Jun 1, 2009 at 10:54 AM, Dmitry
> Eremin-Solenikov<dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hi,
> >
> > As a part of research activities the Embedded Systems - Open Platform Group
> > from Siemens Corporate Technology we are working on adding support for
> > the IEEE 802.15.4 Wireless Personal Area Networks to the Linux. Our current
> > implementation is neither certified nor even feature complete. However
> > we'd like to present current state of our patchset to the Linux developers
> > community to gain comments, fixes, ideas, etc. This is not yet a pull request,
> > but more like an RFC.
> >
> > The project page is available at http://apps.sourceforge.net/trac/linux-zigbee
> > with source code of kernel part available from git at
> > http://zigbee-linux.git.sourceforge.net, mirrored for convenience at
> > git://git.kernel.org/pub/scm/linux/kernel/git/lumag/lowpan.git
> >
> > The source code for userspace utils is available from git at
> > http://linux-zigbee.git.sourceforge.net/
> 
> The Zigbee alliance requires a minimum of $3,500/yr from any company
> making a product based on the spec. How are you going to reconcile
> this requirement with the GPL? They exempt non-commercial users but
> the GPL doesn't allow code to be free for one purpose and pay for
> another.
> 
> "The ZigBee Specification is available to individuals, companies and
> institutions free of charge for all non-commercial purposes (including
> university research, technical evaluation, and development of
> non-commercial software, tools, or documentation). For ease of use,
> clearly marked errata have been incorporated into this document. These
> errata may not have been subjected to an Intellectual Property review,
> and as such, may contain undeclared Necessary Claims. No part of this
> specification may be used in development of a product for sale without
> becoming a member of ZigBee Alliance. Copyright ? ZigBee Alliance,

Confusing legaleese, and probably void, too. If you can get hard copy
of that book, and make sure your implementation is not derived work of
that book, you are safe -- w.r.t. copyright. Someone would have to
research the patents, or just move out of US.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
