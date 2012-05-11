From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] etherdevice.h: Add ether_addr_equal_64bits
Date: Thu, 10 May 2012 23:35:41 -0400 (EDT)
Message-ID: <20120510.233541.852199665039697310.davem@davemloft.net>
References: <cover.1336618707.git.joe@perches.com>
	<7535e70ceb63f7da56f73cb37d4b269cd7798583.1336618708.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7535e70ceb63f7da56f73cb37d4b269cd7798583.1336618708.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed,  9 May 2012 20:04:03 -0700

> Add an optimized boolean function to check if
> 2 ethernet addresses are the same.
> 
> This is to avoid any confusion about compare_ether_addr_64bits
> returning an unsigned, and not being able to use the
> compare_ether_addr_64bits function for sorting ala memcmp.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
