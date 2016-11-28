From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2] bpf: cgroup: fix documentation of
 __cgroup_bpf_update()
Date: Mon, 28 Nov 2016 11:34:31 -0800
Message-ID: <20161128193430.GB6722@ast-mbp.thefacebook.com>
References: <1480338664-22616-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1480338664-22616-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 02:11:04PM +0100, Daniel Mack wrote:
> There's a 'not' missing in one paragraph. Add it.
> 
> Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
> Reported-by: Rami Rosen <roszenrami-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Fixes: 3007098494be ("cgroup: add support for eBPF programs")

Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

btw more canonical patch format is to put Fixes tag before SOB.
