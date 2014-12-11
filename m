From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v8 1/7] cxgb4i: fix tx immediate data credit check
Date: Wed, 10 Dec 2014 22:54:45 -0500 (EST)
Message-ID: <20141210.225445.458745535803327140.davem@davemloft.net>
References: <201412102111.sBALB6sI011656@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201412102111.sBALB6sI011656@localhost6.localdomain6>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karen Xie <kxie@chelsio.com>
Date: Wed, 10 Dec 2014 13:11:06 -0800

> From: Karen Xie <kxie@chelsio.com>
> 
> Only data skbs need the wr header added while control skbs do not. Make sure they are treated differently.
> 
> Signed-off-by: Karen Xie <kxie@chelsio.com>

Please text format your commit messages to 80 characters or less per
line.

People are going to read your commits using text tools, not
necessarily GUI tools which will auto-format your commit message.

I know this seems like we are being difficult, but you are making many
fundamental mistakes in your efforts to merge in these changes.
