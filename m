From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 20:34:22 -0500 (EST)
Message-ID: <20161219.203422.500916400463091702.davem@davemloft.net>
References: <20161219205631.GA31242@ast-mbp.thefacebook.com>
        <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
        <20161220000254.GA58895@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org, mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org,
        keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161220000254.GA58895-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 19 Dec 2016 16:02:56 -0800

> huh? 'not right api' because it's using bpf syscall instead
> of cgroup control-file? I think the opposite is the truth.

I completely agree with Alexei on this.
