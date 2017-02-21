From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH v2] RDS: Make user visible data types
 consistent with rest of the kernel
Date: Mon, 20 Feb 2017 22:18:12 -0500 (EST)
Message-ID: <20170220.221812.707399155770011177.davem@davemloft.net>
References: <1487629013-4972-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487629013-4972-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Mon, 20 Feb 2017 14:16:53 -0800

> Use "__uX/__sX" kernel types rather than current uint*/int* for
> entire file.
> 
> Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
> v1->v2:
> As suggested by David Miller, cleaned up entire header to use kernel types.

Dmitry Levin already submitted a patch the other day which does this,
and it is already in net-next.
