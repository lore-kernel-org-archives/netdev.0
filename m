From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix skb leak in af_irda.c
Date: Tue, 4 Nov 2003 16:28:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104162805.78d6ab4c.davem@redhat.com>
References: <20031101051931.GI3705@conectiva.com.br>
	<20031104224201.GA15041@bougret.hpl.hp.com>
	<20031104153042.416b9c36.davem@redhat.com>
	<20031105002930.GA16055@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20031105002930.GA16055@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2003 16:29:30 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> 	I personally would prefer the following patch. The difference
> is mostly cosmetic. Tested with 2.6.0-test9. Anyway, both patches are
> obviously correct.

Applied, with attribution also given to Arnaldo.

Thanks.
