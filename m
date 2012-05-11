From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net,drivers/net: Convert compare_ether_addr_64bits
 to ether_addr_equal_64bits
Date: Thu, 10 May 2012 23:35:54 -0400 (EDT)
Message-ID: <20120510.233554.263340913611469229.davem@davemloft.net>
References: <cover.1336618707.git.joe@perches.com>
	<acb363688c8ed729cc61e288605cdb4aa4089149.1336618708.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <acb363688c8ed729cc61e288605cdb4aa4089149.1336618708.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed,  9 May 2012 20:04:04 -0700

> Use the new bool function ether_addr_equal_64bits to add
> some clarity and reduce the likelihood for misuse of
> compare_ether_addr_64bits for sorting.
> 
> Done via cocci script:
 ...
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
