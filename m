From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 7/8] netfilter: prepare xt_cgroup for multi revisions
Date: Mon, 14 Dec 2015 20:35:31 +0100
Message-ID: <20151214193531.GA18238@salvia>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <1449527935-27056-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, kadlec@blackhole.kfki.hu,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, ninasc@fb.com,
	Jan Engelhardt <jengelh@inai.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449527935-27056-8-git-send-email-tj@kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 05:38:54PM -0500, Tejun Heo wrote:
> xt_cgroup will grow cgroup2 path based match.  Postfix existing
> symbols with _v0 and prepare for multi revision registration.

Applied, thanks.
