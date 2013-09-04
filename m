From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Convert uses of
 compare_ether_addr to ether_addr_equal
Date: Tue, 03 Sep 2013 22:28:18 -0400 (EDT)
Message-ID: <20130903.222818.797621801374088373.davem@davemloft.net>
References: <1378061483.1953.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	users@rt2x00.serialmonkey.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378061483.1953.3.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 01 Sep 2013 11:51:23 -0700

> Use the new bool function ether_addr_equal to add
> some clarity and reduce the likelihood for misuse
> of compare_ether_addr for sorting.
> 
> Done via cocci script: (and a little typing)
 ...
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
