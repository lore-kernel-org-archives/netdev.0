From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netdevice.h: be'ify packet_type
Date: Mon, 23 May 2005 13:09:34 -0700 (PDT)
Message-ID: <20050523.130934.93383300.davem@davemloft.net>
References: <200505211940.59240.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: adobriyan@gmail.com
In-Reply-To: <200505211940.59240.adobriyan@gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 21 May 2005 19:40:59 +0400

> Everybody does
> 
> 	struct packet_type foo_packet_type = {
> 		.type = __constant_htons(ETH_P_FOO);
> 	};
> 
> 5 introduced warnings will be properly fixed later.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks great, patch applied.

Thanks.
