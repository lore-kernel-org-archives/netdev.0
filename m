From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: rtnetlink: use BUG_ON instead of if
 condition followed by BUG
Date: Mon, 23 Oct 2017 05:32:27 +0100 (WEST)
Message-ID: <20171023.053227.68899581454610693.davem@davemloft.net>
References: <20171021004311.GA25170@embeddedor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171021004311.GA25170@embeddedor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Fri, 20 Oct 2017 19:43:11 -0500

> Use BUG_ON instead of if condition followed by BUG in do_setlink.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied.
