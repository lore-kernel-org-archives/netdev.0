From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net: Convert compare_ether_addr to
 ether_addr_equal
Date: Thu, 10 May 2012 23:35:34 -0400 (EDT)
Message-ID: <20120510.233534.836223106369679267.davem@davemloft.net>
References: <cover.1336618707.git.joe@perches.com>
	<7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	ath9k-devel@venema.h4ckr.net
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed,  9 May 2012 20:17:46 -0700

> Use the new bool function ether_addr_equal to add
> some clarity and reduce the likelihood for misuse
> of compare_ether_addr for sorting.
> 
> Done via cocci script:
 ...
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
