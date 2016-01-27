From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cavium: liquidio: use helpers ns_to_timespec64()
Date: Wed, 27 Jan 2016 17:06:46 -0500 (EST)
Message-ID: <20160127.170646.1011877126864428103.davem@davemloft.net>
References: <1453887277-11531-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com, rvatsavayi@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com, guohanjun@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wangkefeng.wang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453887277-11531-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Wed, 27 Jan 2016 17:34:37 +0800

> Convert the driver to use ns_to_timespec64() to keep consistency
> with timespec64_to_ns() instead of open coding the same logic.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Applied, thank you.
