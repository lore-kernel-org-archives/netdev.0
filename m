From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv6/ipv6_syms.c: unexport fl6_sock_lookup
Date: Thu, 02 Jun 2005 13:06:48 -0700 (PDT)
Message-ID: <20050602.130648.75428139.davem@davemloft.net>
References: <20050530205653.GZ10441@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: bunk@stusta.de
In-Reply-To: <20050530205653.GZ10441@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 30 May 2005 22:56:53 +0200

> There is no usage of this EXPORT_SYMBOL in the kernel.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks.
