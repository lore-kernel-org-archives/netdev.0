From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix skb leak in af_irda.c
Date: Tue, 4 Nov 2003 15:30:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104153042.416b9c36.davem@redhat.com>
References: <20031101051931.GI3705@conectiva.com.br>
	<20031104224201.GA15041@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20031104224201.GA15041@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2003 14:42:01 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Sat, Nov 01, 2003 at 03:19:31AM -0200, Arnaldo Carvalho de Melo wrote:
> > Hi David, Jean,
> > 
> > 	Please apply.
> 
> 	Hum... It looks as if it didn't made into the kernel. Ok, I'll
> add that in my patch queue and push that for you ;-)

It isn't in because I was waiting for an acknowledgment
from you Jean :-)
