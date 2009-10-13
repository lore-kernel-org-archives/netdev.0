From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next-2.6] cxgb3: Added private MAC address and
 provisioning packet handler for iSCSI
Date: Tue, 13 Oct 2009 03:47:08 -0700 (PDT)
Message-ID: <20091013.034708.218523749.davem@davemloft.net>
References: <200910081911.n98JB6na024344@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, divy@chelsio.com, rakesh@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759467AbZJMKrO@vger.kernel.org>
In-Reply-To: <200910081911.n98JB6na024344@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: kxie@chelsio.com
Date: Thu, 08 Oct 2009 12:11:05 -0700

> From: Karen Xie <kxie@chelsio.com>
> 
> [PATCH v4 net-next-2.6] cxgb3: Added private MAC address and provisioning packet handler for iSCSI
> 
> This patch added support of private MAC address per port and provisioning
> packet handler for iSCSI traffic only.
> 
> The above changes are isolated to the cxgb3 driver, independent of any scsi or iscsi driver changes.
> 
> Acked-by: Karen Xie <kxie@chelsio.com>
> Acked-by: Divy Le Ray <divy@chelsio.com>
> Signed-off-by: Rakesh Ranjan <rakesh@chelsio.com>

Applied to net-next-2.6, thanks.
