From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH 8/9] netfilter: prepare xt_cgroup for multi revisions
Date: Mon, 23 Nov 2015 13:44:56 +0100
Message-ID: <56530A48.1090703@bmw-carit.de>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lizefan@huawei.com>, <hannes@cmpxchg.org>,
	<netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<coreteam@netfilter.org>, <cgroups@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
	<ninasc@fb.com>, Neil Horman <nhorman@tuxdriver.com>,
	Jan Engelhardt <jengelh@inai.de>
To: Tejun Heo <tj@kernel.org>, <davem@davemloft.net>,
	<pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <daniel@iogearbox.net>,
	<nhorman@tuxdriver.co>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448122441-9335-9-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 11/21/2015 05:14 PM, Tejun Heo wrote:
> xt_cgroup will grow cgroup2 path based match.  Postfix existing
> symbols with _v0 and prepare for multi revision registration.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>

Same as in my reply to patch #9 (yes, I know do it wrong order...
thought can't stop now... :))

Tested-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Daniel Wagner <daniel.wagner@bmw-carit.de>

cheers,
daniel
