From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][INET] move inet_sock into inet_opt and rename it to
 inet_sock
Date: Mon, 27 Dec 2004 21:58:29 -0800
Message-ID: <20041227215829.688bbe74.davem@davemloft.net>
References: <41CE198B.7040005@conectiva.com.br>
	<41D0C4C2.6030000@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41D0C4C2.6030000@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Dec 2004 00:28:18 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

>      Now that 2.6.10 is out and your 2.6.11 queue was merged,
> please take a look if this is acceptable, the following patches
> will deal with udp_sock, tcp_sock, etc.
> 
>      This is the start of the series of patches that will introduce
> struct connection_sock, reducing the memory used by non connected
> protocols, such as UDP.
> 
>      It is available at:
> 
> bk://kernel.bkbits.net/acme/connection_sock-2.6

This looks wonderful.  Pulled, thanks a lot Arnaldo.
