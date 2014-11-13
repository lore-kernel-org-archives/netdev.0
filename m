From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4i/cxgb4 : Refactor macros to conform to
 uniform standards
Date: Thu, 13 Nov 2014 14:36:36 -0500 (EST)
Message-ID: <20141113.143636.2171639048701846459.davem@davemloft.net>
References: <1415841357-19700-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, hch@infradead.org,
	jbottomley@parallels.com, roland@purestorage.com,
	hariprasad@chelsio.com, kxie@chelsio.com,
	swise@opengridcomputing.com
To: anish@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1415841357-19700-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anish Bhatt <anish@chelsio.com>
Date: Wed, 12 Nov 2014 17:15:57 -0800

> Refactored all macros used in cxgb4i as part of previously started cxgb4 macro
> names cleanup. Makes them more uniform and avoids namespace collision.
> Minor changes in other drivers where required as some of these macros are used
>  by multiple drivers, affected drivers are iw_cxgb4, cxgb4(vf) & csiostor
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

Applied, thanks.
