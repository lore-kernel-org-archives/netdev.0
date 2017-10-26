From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: ib: Fix uninitialized variable
Date: Thu, 26 Oct 2017 17:36:34 +0900 (KST)
Message-ID: <20171026.173634.65691737854122389.davem@davemloft.net>
References: <20171024161718.18076-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: Haakon.Bugge@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024161718.18076-1-Haakon.Bugge@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Håkon Bugge <Haakon.Bugge@oracle.com>
Date: Tue, 24 Oct 2017 18:17:18 +0200

> send_flags needs to be initialized before calling
> rds_ib_set_wr_signal_state().
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied.
