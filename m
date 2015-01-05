From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] RDMA/cxgb4/cxgb4vf/csiostor: Cleanup
 register defines
Date: Mon, 05 Jan 2015 16:35:28 -0500 (EST)
Message-ID: <20150105.163528.2285094223396327404.davem@davemloft.net>
References: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, JBottomley@parallels.com,
	hch@infradead.org, roland@purestorage.com, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, praveenm@chelsio.com,
	swise@opengridcomputing.com
To: hariprasad@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1420455647-23094-1-git-send-email-hariprasad@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  5 Jan 2015 16:30:42 +0530

> This series continues to cleanup all the macros/register defines related to
> SGE, PCIE, MC, MA, TCAM, MAC, etc that are defined in t4_regs.h and the
> affected files.
> 
> Will post another 1 or 2 series so that we can cover all the macros so that
> they all follow the same style to be consistent.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4, cxgb4vf, iw_cxgb4 and csiostor driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
