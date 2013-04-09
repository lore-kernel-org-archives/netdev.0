From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_memcontrol: remove a redundant statement in
 tcp_destroy_cgroup()
Date: Tue, 09 Apr 2013 13:19:56 -0400 (EDT)
Message-ID: <20130409.131956.1617262364252663466.davem@davemloft.net>
References: <5163AE40.40304@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizefan@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5163AE40.40304@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizefan@huawei.com>
Date: Tue, 9 Apr 2013 13:59:28 +0800

> We read the value but make no use of it.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Applied.
