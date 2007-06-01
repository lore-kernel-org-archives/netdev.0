From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Please pull 'libertas' branch of wireless-2.6
Date: Fri, 01 Jun 2007 17:48:18 -0400
Message-ID: <1180734498.30974.1.camel@xo-28-0B-88.localdomain>
References: <20070529183347.GD3496@tuxdriver.com>
	 <465D8538.8070507@garzik.org>
	 <1180538928.17163.10.camel@xo-28-0B-88.localdomain>
	 <1180645997.18078.8.camel@xo-28-0B-88.localdomain>
	 <20070531211605.GA30161@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070531211605.GA30161-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-31 at 17:16 -0400, John W. Linville wrote:
> On Thu, May 31, 2007 at 05:13:17PM -0400, Dan Williams wrote:
> > On Wed, 2007-05-30 at 11:28 -0400, Dan Williams wrote:
> > > On Wed, 2007-05-30 at 10:07 -0400, Jeff Garzik wrote:
> > > > John W. Linville wrote:
> > > > > Lots of stuff here...probably best for 2.6.23...
> > > > 
> > > > Is this best for Linux users... or just easy for developers?
> > > > 
> > > > Won't putting off all these fixes until 2.6.23 leave the driver released 
> > > > in 2.6.22 in shoddy shape?
> 
> > > If you think all the bits from this should just go to 2.6.22, that's
> > > fine with me.  But I don't feel comfortable making that call given what
> > > I thought were the constraints on pushing changes through during an rc
> > > cycle.  When the merge window was open, we backported critical bug fixes
> > > and necessary merge-requirement cleanups to the code in linville's tree,
> > > but avoided changes that didn't impact function.
> > 
> > Any response on these points yet?  I've got yet more cleanups and a few
> > other things queued in libertas-2.6 but I'd like to see where this
> > discussion goes before sending a pull request for the new bits.
> 
> As for me, I have no great problem w/ the whole batch going to 2.6.22.
> The driver is still new and most acknowledge it still has significant
> defficiencies.  Most (but probably not all) of the patches would seem
> to fit some definition of bug fix anyway.  I was just trying to err
> on the side of caution and follow the normal "bugfixes in -rc" process.
> 
> Jeff, the branch in question is based off a vanilla 2.6.22-rc3.
> So it is safe to pull (from a "won't mess-up my tree" perspective)
> if you are so inclined.

Ok; if Jeff is so inclined, we'll push further libertas
cleanups/bugfixes/etc to you, and then you upstream to Jeff, targetted
for inclusion in 2.6.22.

Dan
