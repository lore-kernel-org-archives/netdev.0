From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/802/: some cleanups
Date: Mon, 17 Jan 2005 14:37:38 -0800
Message-ID: <20050117143738.0cf1ed02.davem@davemloft.net>
References: <20041212201115.GU22324@stusta.de>
	<20041227184923.5b26f5a0.davem@davemloft.net>
	<20050117081438.GE4274@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050117081438.GE4274@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Jan 2005 09:14:38 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Mon, Dec 27, 2004 at 06:49:23PM -0800, David S. Miller wrote:
> > 
> > drivers/net/net_init.c no longer exists in the source tree :)
> 
> Updated patch:
> 
> 
> <--  snip  -->
> 
> 
> This patch contains the following cleanups:
> - make some needlessly global code static
> - net/802/hippi.c: remove the unused global function hippi_net_init
> - net/8021q/vlan.c: remove the global variable vlan_default_dev_flags
>                     that was never changed
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
