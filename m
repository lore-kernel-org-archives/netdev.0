From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 09 Jul 2012 19:37:56 -0700 (PDT)
Message-ID: <20120709.193756.807327669543104730.davem@davemloft.net>
References: <4FFA9321.4030407@cn.fujitsu.com>
	<20120709.145125.1903343847210013668.davem@davemloft.net>
	<4FFB9473.4040203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizefan@huawei.com, tj@kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFB9473.4040203@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Tue, 10 Jul 2012 10:33:23 +0800

> Please see my patch in this thread, I think it's a better way to fix this bug.

You'll need to work that out with Eric, fwiw I think his patch was
clean and just fine and it's staying in my tree.
