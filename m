From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/rxrpc/: misc possible cleanups
Date: Mon, 27 Dec 2004 21:18:04 -0800
Message-ID: <20041227211804.4365c340.davem@davemloft.net>
References: <20041215012612.GG12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215012612.GG12937@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 02:26:12 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contains the following possible cleanups:
> - make some needlessly global code static
> - remove the following unused global function:
>   - transport.c: rxrpc_clear_transport
> - remove the following unneeded EXPORT_SYMBOL:
>   - rxrpc_syms.c: rxrpc_call_flush

Looks good, applied.

Thanks Adrian.
