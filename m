From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] RDS: IB: Limit the scope of has_fr/has_fmr
 variables
Date: Thu, 05 Oct 2017 21:16:49 -0700 (PDT)
Message-ID: <20171005.211649.85264168575002634.davem@davemloft.net>
References: <1507144244-1611-1-git-send-email-avinash.repaka@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: avinash.repaka@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507144244-1611-1-git-send-email-avinash.repaka@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avinash Repaka <avinash.repaka@oracle.com>
Date: Wed,  4 Oct 2017 12:10:43 -0700

> This patch fixes the scope of has_fr and has_fmr variables as they are
> needed only in rds_ib_add_one().
> 
> Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied to net-next.
