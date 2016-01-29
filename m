From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: ixp46x: use helpers for converting ns to timespec
Date: Fri, 29 Jan 2016 12:39:15 -0800 (PST)
Message-ID: <20160129.123915.1882302350611367146.davem@davemloft.net>
References: <1453948039-3198-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, guohanjun@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wangkefeng.wang@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453948039-3198-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Thu, 28 Jan 2016 10:27:19 +0800

> Convert the driver to use ns_to_timespec64() and timespec64_to_ns()
> instead of open coding the same logic.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Applied, thanks.
