From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET v3] netfilter, cgroup: implement cgroup2 path match
 in xt_cgroup
Date: Mon, 23 Nov 2015 15:45:23 -0500 (EST)
Message-ID: <20151123.154523.125969708507852672.davem@davemloft.net>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.co, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, ninasc@fb.com
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448122441-9335-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Sat, 21 Nov 2015 11:13:52 -0500

> * Refreshed on top of Nina's net_cls dynamic config update fix patch.
>   I included the fix patch as part of this series to ease reviewing.

I put this into the 'net' tree as it's a bug fix, so can you respin
this after I next merge 'net' into 'net-next'?  I'll let you know.

There'll probably be at least some minor feedback meanwhile anyways.

Thanks.
