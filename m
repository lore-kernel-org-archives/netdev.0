From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/4] add mac80211 wireless infrastructure
Date: Sat, 5 May 2007 10:33:36 +0100
Message-ID: <20070505093336.GA9307@infradead.org>
References: <20070505031749.GA5308@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070505031749.GA5308-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 11:17:49PM -0400, John W. Linville wrote:
> This series adds the mac80211 component.  This is the new wireless
> infrastructure for "softmac"-style wireless hardware.  It originated
> as code contributed by Devicescape, and has been under development by
> the community for well over a year.  Thanks are due especially to Jiri
> Benc and Michael Wu as well as Johannes Berg and a number of other
> contributors who have worked to hammer this into its current form.
> 
> This component was in -mm for most of the 2.6.21 cycle, with few
> reported bugs.  The code is also currently available in Fedora rawhide
> where it has performed well.
> 
> The wireless developers would like this to be considered for merge
> in time for 2.6.22.  Patches for at least one mac80211-based driver
> will follow shortly.

Please send out patches for review first.  Last time I looked through
the stuff in -mm there were a lot of things that were in pretty bad
shape still.
