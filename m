From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove net_init.c ifdef clutter
Date: Sat, 13 Nov 2004 23:13:42 -0800
Message-ID: <20041113231342.71fb73d3.davem@davemloft.net>
References: <20041101130144.GA8727@lst.de>
	<20041110165641.GA29705@lst.de>
	<20041111145058.0fc24412.davem@davemloft.net>
	<4196FDD8.7000302@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <4196FDD8.7000302@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Nov 2004 04:40:24 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Dave, you missed the new file net/appletalk/dev.c, i.e. it is not
> in Linus tree.

Yeah I just noticed that, crap.

It's one thing a build verify doesn't catch, a forgotten
"bk new" like this.

Sorry, will send the fix to Linus shortly.
