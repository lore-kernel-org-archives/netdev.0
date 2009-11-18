From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.32] cxgb3: fix premature page unmap
Date: Wed, 18 Nov 2009 05:11:41 -0800 (PST)
Message-ID: <20091118.051141.194815090.davem@davemloft.net>
References: <20091118023828.16411.57681.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756904AbZKRNLZ@vger.kernel.org>
In-Reply-To: <20091118023828.16411.57681.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Tue, 17 Nov 2009 18:38:28 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> unmap Rx page only when guaranteed that this page won't be
> used anymore to allocate rx page chunks.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied to net-2.6, thanks.
