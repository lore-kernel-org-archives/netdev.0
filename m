From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] - Fixes sparse warning in ipv6/ipv6_sockglue.c
Date: Mon, 14 Nov 2005 21:43:49 -0800 (PST)
Message-ID: <20051114.214349.74490724.davem__44274.6139633984$1132034190$gmane$org@davemloft.net>
References: <20051114095422.5cc4727f.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lcapitulino@mandriva.com.br
In-Reply-To: <20051114095422.5cc4727f.lcapitulino@mandriva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Date: Mon, 14 Nov 2005 09:54:22 -0200

> The patch below fixes the following sparse warning:
> 
> net/ipv6/ipv6_sockglue.c:291:13: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@mandriva.com.br>

Applied, thanks.
