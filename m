From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Re: [PATCH] rdma/cm: Randomize local port allocation.
Date: Fri, 16 Apr 2010 22:54:22 +0900
Message-ID: <201004162254.FJF73478.SHOOMOFtQFVJLF@I-love.SAKURA.ne.jp>
References: <201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
	<195EB1AD388F455AA386EB214FCD09F4@amr.corp.intel.com>
	<201004150229.o3F2T4dZ054768@www262.sakura.ne.jp>
	<5CE6BC7B954643FAAFFD2AD66F673CBD@amr.corp.intel.com>
	<4BC7C9CF.20403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4BC7C9CF.20403-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Cong Wang wrote:
> Sean Hefty wrote:
> > I like this version, thanks!  I'm not sure which tree to merge it through.
> > Are you needing this for 2.6.34, or is 2.6.35 okay?
> > 
> 
> As soon as possible, so 2.6.34. :)
> 
Cong, merge window for 2.6.34 was already closed.
You need to make your patchset towards 2.6.35 (using net-next-2.6 tree)
rather than 2.6.34 (using linux-2.6 tree). Therefore, this patch being
queued for 2.6.35 (through net-next-2.6 tree) should be okay for you.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
