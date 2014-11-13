From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 13 Nov 2014 16:14:05 -0500 (EST)
Message-ID: <20141113.161405.1383394554354192003.davem@davemloft.net>
References: <20141113113555.15117365@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, hariprasad@chelsio.com,
	alexander.h.duyck@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20141113113555.15117365@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 13 Nov 2014 11:35:55 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/chelsio/cxgb4vf/sge.c between commit 65f6ecc93e7c
> ("cxgb4vf: Move fl_starv_thres into adapter->sge data structure") from
> the net tree and commit aa9cd31c3f3e ("cxgb4/cxgb4vf: Replace
> __skb_alloc_page with __dev_alloc_page") from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

This merge resolution looks perfect.
