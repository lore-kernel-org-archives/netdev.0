From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 4/6] netprio_cgroup: use IS_ENABLED() and family
Date: Wed, 1 Feb 2012 07:02:09 -0500
Message-ID: <20120201120209.GA12818@hmsreliant.think-freely.org>
References: <4F28E203.10502@cn.fujitsu.com>
 <20120201.015954.2098592611164231843.davem@davemloft.net>
 <4F28E48D.3040505@cn.fujitsu.com>
 <20120201.020738.1965865410881089752.davem@davemloft.net>
 <4F28E853.7000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F28E853.7000104-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 01, 2012 at 03:22:59PM +0800, Li Zefan wrote:
> >>> Do not mix genuine bug fixes and cleanups.
> >>>
> >>> Otherwise I cannot apply your bug fixes to the 'net' tree.
> >>>
> >>> Seperate things out, submit only pure bug fixes first, then
> >>> later once those changes propagate you can submit the cleanups.
> >>>
> >>
> >> I did seperate them out, so the first three patches are fixes,
> >> and others are cleanups. I can resend cleanup patches once
> >> fixes hit mainline.
> > 
> > Seperate them in different groups, don't submit them as one
> > collection.  And definitely don't submit them all at the
> > same damn time!  You have to wait with the dependent cleanups
> > until the fixes go in, and subsequently show up in my net-next
> > tree.
> > 
> > I'm not applying this stuff until you submit it properly, in
> > two stages.
> > 
> 
> I'll do this when I get some comments/acks.
> 

The changes look fine to me.
I'll ack them once you submit them properly.
Thanks
Neil
