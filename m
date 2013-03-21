From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove redundant ifdef CONFIG_CGROUPS
Date: Thu, 21 Mar 2013 11:49:00 -0400 (EDT)
Message-ID: <20130321.114900.1573555053097095750.davem@davemloft.net>
References: <514A767B.7000307@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizefan@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514A767B.7000307@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizefan@huawei.com>
Date: Thu, 21 Mar 2013 10:54:51 +0800

> The cgroup code has been surrounded by ifdef CONFIG_NET_CLS_CGROUP
> and CONFIG_NETPRIO_CGROUP.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Applied, thanks.
