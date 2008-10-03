From: Greg KH <greg@kroah.com>
Subject: Re: atl2 network driver status
Date: Fri, 3 Oct 2008 15:00:31 -0700
Message-ID: <20081003220031.GC14890@kroah.com>
References: <20081002230246.GA11570@kroah.com> <20081002181731.6b8f563d@osprey.hogchain.net> <20081002232148.GA20003@kroah.com> <20081002182943.0264f7fa@osprey.hogchain.net> <20081002183503.73674682@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiong.huang@atheros.com, csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48612 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbYJCXqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 19:46:48 -0400
Content-Disposition: inline
In-Reply-To: <20081002183503.73674682@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 02, 2008 at 06:35:03PM -0500, Jay Cliburn wrote:
> On Thu, 2 Oct 2008 18:29:43 -0500
> Jay Cliburn <jcliburn@gmail.com> wrote:
> 
> > On Thu, 2 Oct 2008 16:21:48 -0700
> > Greg KH <greg@kroah.com> wrote:
> > 
> > > On Thu, Oct 02, 2008 at 06:17:31PM -0500, Jay Cliburn wrote:
> > > > On Thu, 2 Oct 2008 16:02:46 -0700
> > > > Greg KH <greg@kroah.com> wrote:
> > > > 
> > > > > Hi,
> > > > > 
> > > > > In looking for drivers to add to drivers/staging/ I ran across
> > > > > the atl2 driver that is currently in the Fedora and Ubuntu
> > > > > kernel trees.
> > > > > 
> > > > > This driver doesn't look to be scheduled for inclusion in the
> > > > > upstream netdev git tree for submission for 2.6.28, is there any
> > > > > reason why it is still out-of-the-tree?
> > > > 
> > > > Hi Greg,
> > > > 
> > > > It's in net-next-2.6.
> > > > 
> > > > http://marc.info/?l=linux-netdev&m=122144021209242&w=2
> > > 
> > > Nice, so that means it's going to be in 2.6.28?
> > 
> > I think so.  As I understand it, net-next-2.6 is Dave Miller's git
> > tree for stuff destined for 2.6.28.
> 
> Yep, here it is: Dave's description of his two main trees.
> 
> So atl2 will be in 2.6.28.

Ah, sorry for the noise, I should have remembered this.  Thanks for
pointing it out.

greg k-h
