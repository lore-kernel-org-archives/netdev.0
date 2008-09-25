From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-09-24
Date: Thu, 25 Sep 2008 11:47:54 -0400
Message-ID: <20080925154753.GA3277@tuxdriver.com>
References: <20080924231720.GD3639@tuxdriver.com> <1222321622.2510.455.camel@debian.sh.intel.com> <20080925114133.GA5044@tuxdriver.com> <1ba2fa240809250757x32aa450k523d71e555c221e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1ba2fa240809250757x32aa450k523d71e555c221e4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 25, 2008 at 05:57:33PM +0300, Tomas Winkler wrote:
> On Thu, Sep 25, 2008 at 2:41 PM, John W. Linville
> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> > On Thu, Sep 25, 2008 at 01:47:02PM +0800, Zhu Yi wrote:
> >> On Wed, 2008-09-24 at 17:17 -0600, John W. Linville wrote:
> >> > Dave,
> >> >
> >> > One more for 2.6.27 -- a fix for a possible interrupt storm.  There is
> >> > even a link in the commit log to a youtube video of the storm in
> >> > progress. :-)
> >> >
> >> > Let me know if there are problems!
> >>
> >> Can you also add this one? It doesn't panic the kernel when a frame from
> >> firmware is invalid.
> >>
> >> http://marc.info/?l=linux-wireless&m=122219037706528&w=2
> >
> > Is there an open bug report for that anywhere?  Is this something
> > that real users (no offense to Johannes) are likely to hit?
> 
> I'm just exporting the major bugs from our internal database to
> buzilla, 5000 is new so
> we are hitting the problems during testing  before users report them.
> 
> Now I don't know if it was good idea to push the driver upstream same
> time as it hits the market.

You're right -- pushing it sooner rather than sitting on it internally
probably would have helped to give it more visibility sooner.

John
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
