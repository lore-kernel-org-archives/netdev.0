From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDS: use rb_entry()
Date: Tue, 20 Dec 2016 14:23:22 -0500 (EST)
Message-ID: <20161220.142322.1578566298966214653.davem@davemloft.net>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
        <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Tue, 20 Dec 2016 22:02:18 +0800

> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
