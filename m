From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Fix ingress qdisc to pick up IPv6 packets
 when using netfilter hooks
Date: Wed, 2 Feb 2005 13:07:43 -0800
Message-ID: <20050202130743.065bc627.davem@davemloft.net>
References: <20050131184827.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131184827.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 19:48:27 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Jamal, close your eyes please.

:-)
 
> Fixes the ingress qdisc to pick up IPv6 packets when using the old
> style netfilter hooks, i.e. when CONFIG_NET_CLS_ACT is not enabled.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
