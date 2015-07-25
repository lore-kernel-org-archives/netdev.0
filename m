From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cgroup: net_cls: fix false-positive "suspicious RCU
 usage"
Date: Sat, 25 Jul 2015 00:13:35 -0700 (PDT)
Message-ID: <20150725.001335.537916645321123530.davem@davemloft.net>
References: <20150721164629.18385.14538.stgit@buzz>
	<20150722092320.30663.86742.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tj@kernel.org, cgroups@vger.kernel.org,
	lizefan@huawei.com, linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150722092320.30663.86742.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Wed, 22 Jul 2015 12:23:20 +0300

> In dev_queue_xmit() net_cls protected with rcu-bh.
 ...
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied, thanks.
