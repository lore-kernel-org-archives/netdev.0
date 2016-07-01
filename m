From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v3 0/4] cgroup: bpf: cgroup2 membership test
 on skb
Date: Fri, 01 Jul 2016 16:26:06 -0400 (EDT)
Message-ID: <20160701.162606.549473968684555391.davem@davemloft.net>
References: <1467307725-1948415-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org
To: kafai-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467307725-1948415-1-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Date: Thu, 30 Jun 2016 10:28:41 -0700

> This series is to implement a bpf-way to
> check the cgroup2 membership of a skb (sk_buff).
> 
> It is similar to the feature added in netfilter:
> c38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")
> 
> The current target is the tc-like usage.

I'll apply this series, but the colloqual way to arrange this header
posting is to keep the overview and description of the series at the
top of the text, and then have the "v3 ..., v2 ..." changelog afterwards.
