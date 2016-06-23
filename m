From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v2 1/4] cgroup: Add cgroup_get_from_fd
Date: Thu, 23 Jun 2016 17:11:46 -0400
Message-ID: <20160623211146.GJ3262@mtj.duckdns.org>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com>
 <1466630252-3822277-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466630252-3822277-2-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2016 at 02:17:29PM -0700, Martin KaFai Lau wrote:
> Add a helper function to get a cgroup2 from a fd.  It will be
> stored in a bpf array (BPF_MAP_TYPE_CGROUP_ARRAY) which will
> be introduced in the later patch.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>

 Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route this patch with the rest of the series.  If
it's preferable to apply this to the cgroup branch, please let me
know.

Thanks!

-- 
tejun
