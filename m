From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: sch_netem: use rb_entry()
Date: Tue, 20 Dec 2016 14:23:16 -0500 (EST)
Message-ID: <20161220.142316.1701175453489831251.davem@davemloft.net>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
        <dc6e312e4e2ff3868d1791032c329477d27ba50b.1482204694.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jhs@mojatatu.com,
        netem@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dc6e312e4e2ff3868d1791032c329477d27ba50b.1482204694.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Tue, 20 Dec 2016 22:02:16 +0800

> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
