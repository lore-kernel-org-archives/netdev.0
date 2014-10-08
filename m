From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: description of dma_cookie cause make xmldocs
 warning
Date: Wed, 08 Oct 2014 16:08:59 -0400 (EDT)
Message-ID: <20141008.160859.1038322519780535077.davem@davemloft.net>
References: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dan.j.williams@intel.com
To: standby24x7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masanari Iida <standby24x7@gmail.com>
Date: Wed,  8 Oct 2014 23:53:39 +0900

> In commit 7bced397510ab569d31de4c70b39e13355046387,
> dma_cookie was removed from struct skbuff.
> But the description of dma_cookie still exist.
> So the "make xmldocs" output following warning.
> 
> Warning(.//include/linux/skbuff.h:609): Excess struct/union
> /enum/typedef member 'dma_cookie' description in 'sk_buff'
> 
> Remove description of dma_cookie fix the symptom.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied.
