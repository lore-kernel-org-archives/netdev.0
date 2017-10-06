From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] RDS: IB: Initialize max_items based on
 underlying device attributes
Date: Thu, 05 Oct 2017 21:16:57 -0700 (PDT)
Message-ID: <20171005.211657.143790379628391324.davem@davemloft.net>
References: <1507144289-1690-1-git-send-email-avinash.repaka@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: avinash.repaka@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507144289-1690-1-git-send-email-avinash.repaka@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avinash Repaka <avinash.repaka@oracle.com>
Date: Wed,  4 Oct 2017 12:11:29 -0700

> Use max_1m_mrs/max_8k_mrs while setting max_items, as the former
> variables are set based on the underlying device attributes.
> 
> Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied to net-next.
