From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (5/17) ddp -- size_t for send/recvmsg
Date: Thu, 8 Jan 2004 20:05:30 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108220530.GB3062@conectiva.com.br>
References: <20040109134436.6aa8fe1f@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040109134436.6aa8fe1f@linux.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Jan 09, 2004 at 01:44:36PM -0800, Stephen Hemminger escreveu:
> Change send/recvmsg to match prototype change in sock.h
> 
> diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> --- a/net/appletalk/ddp.c	Mon Dec  8 16:19:43 2003
> +++ b/net/appletalk/ddp.c	Mon Dec  8 16:19:43 2003
> @@ -1552,7 +1552,7 @@

I'm OK with this, thanks Stephen.

- Arnaldo
