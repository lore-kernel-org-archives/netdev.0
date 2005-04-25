From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][IPV6] export inet6_sock_nr
Date: Sun, 24 Apr 2005 20:23:29 -0700
Message-ID: <20050424202329.5d03e045.davem@davemloft.net>
References: <20050417225433.GC10626@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
In-Reply-To: <20050417225433.GC10626@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Apr 2005 19:54:33 -0300
acme@ghostprotocols.net (Arnaldo Carvalho de Melo) wrote:

> 	Please apply, SCTP/DCCP needs this.

... when INET_REFCNT_DEBUG is defined :-)

> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Applied, but...

> --- net/ipv6/af_inet6.c	(revision 57)
> +++ net/ipv6/af_inet6.c	(working copy)

please -p1 root your patches :-)
