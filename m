From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hsr: Use ether_addr_copy
Date: Tue, 18 Feb 2014 18:14:55 -0500 (EST)
Message-ID: <20140218.181455.1318635286870307922.davem@davemloft.net>
References: <675e6a59ebb87d5e18633df578a62a1202f6172e.1392748500.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arvid.brodin@alten.se,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <675e6a59ebb87d5e18633df578a62a1202f6172e.1392748500.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 18 Feb 2014 10:37:20 -0800

> It's slightly smaller/faster for some architectures.
> Make sure def_multicast_addr is __aligned(2)
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
