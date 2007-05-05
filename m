From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 0/4] add mac80211 wireless infrastructure
Date: Sat, 5 May 2007 12:00:56 -0400
Message-ID: <20070505160056.GH4155@tuxdriver.com>
References: <20070505031749.GA5308@tuxdriver.com> <20070505093336.GA9307@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070505093336.GA9307-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 05, 2007 at 10:33:36AM +0100, Christoph Hellwig wrote:
> On Fri, May 04, 2007 at 11:17:49PM -0400, John W. Linville wrote:

> > This component was in -mm for most of the 2.6.21 cycle, with few
> > reported bugs.  The code is also currently available in Fedora rawhide
> > where it has performed well.
> > 
> > The wireless developers would like this to be considered for merge
> > in time for 2.6.22.  Patches for at least one mac80211-based driver
> > will follow shortly.
> 
> Please send out patches for review first.  Last time I looked through
> the stuff in -mm there were a lot of things that were in pretty bad
> shape still.

I had a little email trouble w/ the orignal patch post.  I hand edited
some headers and I must have screwed them up.

Anyway, the patches have been reposted and they seem to have made
it through to the list.  Please do look at them -- I'm sure they can
benefit from your loving eye.  :-)

The patches are also available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/mac80211/

I realize this is a bit late in the merge cycle -- this timing is the
best we could manage.  If the patches are fatally flawed then we can
try for 2.6.23.  But if possible, we would like to get them into the
current cycle.

FWIW, the patches have been paired-down a bit from what is in -mm,
including the removal of AP and WDS mode support and related ioctls.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
