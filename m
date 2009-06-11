From: Sergey Lapin <slapin@ossfans.org>
Subject: Re: [PULL REQUEST] IEEE 802.15.4 stack: generic parts v4
Date: Thu, 11 Jun 2009 07:52:35 +0400
Message-ID: <20090611035234.GC17271@build.ossfans.org>
References: <cover.1244498867.git.slapin@ossfans.org> <20090609.050706.241520518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, dbaryshkov@gmail.com, sfr@canb.auug.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from build.ossfans.org ([67.223.233.67]:59852 "EHLO
	build.ossfans.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756033AbZFKDwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 23:52:43 -0400
Content-Disposition: inline
In-Reply-To: <20090609.050706.241520518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 05:07:06AM -0700, David Miller wrote:
> From: Sergey Lapin <slapin@ossfans.org>
> Date: Tue,  9 Jun 2009 02:18:46 +0400
> 
> > Major changes from previous post:
> >  * Changed net/ieee802154/Makefile according to Sam Ravnborg suggestion
> > 
> > The following changes since commit 81ee1bad86bd6752c626018d43a74e3f81f1ae72:
> >   Linus Torvalds (1):
> >         Merge branch 'for-linus' of git://git.kernel.org/.../viro/vfs-2.6
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/slapin/lowpan.git for-next
> 
> I can't pull from a tree that is prepared like this.
> 
> You have to make a clean clone of the net-next-2.6 GIT tree and
> add your changes on top of that.  When you use a clone of
> Linus's tree, I'm going to end up getting all kinds of changes
> from upstream that I haven't merged into net-next-2.6 yet which
> creates a complete mess.
Sorry, we did not know about that. But we'll do that next time.

> 
> I'm going to apply these changes by hand.
Thanks a lot!

S.

