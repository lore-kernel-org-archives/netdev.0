From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netprio_cgroup: remove task_struct parameter from
 sock_update_netprio()
Date: Tue, 09 Apr 2013 13:20:13 -0400 (EDT)
Message-ID: <20130409.132013.1347023271670733458.davem@davemloft.net>
References: <5163AF37.8010605@huawei.com>
	<5163AF43.502@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com
To: lizefan@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5163AF43.502@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizefan@huawei.com>
Date: Tue, 9 Apr 2013 14:03:47 +0800

> The callers always pass current to sock_update_netprio().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Applied.
