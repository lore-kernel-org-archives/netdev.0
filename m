From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: sch_fq: use rb_entry()
Date: Tue, 20 Dec 2016 14:23:11 -0500 (EST)
Message-ID: <20161220.142311.1803222502945883312.davem@davemloft.net>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
        <6aa180710d70b09d4f81d3d219b3161077e1ff11.1482204526.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6aa180710d70b09d4f81d3d219b3161077e1ff11.1482204526.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Tue, 20 Dec 2016 22:02:15 +0800

> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
