From: Fabio Massimo Di Nitto <fabbione@fabbione.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 16:22:07 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0301081616230.6523@trider-g7.ext.fabbione.net>
References: <20030108130850.GQ22951@wiggy.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20030108130850.GQ22951@wiggy.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

On Wed, 8 Jan 2003, Wichert Akkerman wrote:

> tornado.wiggy.net is my client running Linux 2.4.19 (unpatched, UP machine),
> and 2001:968:1::2 is the icecast server running Linux 2.4.20-rc2-ac3 (SMP).
> If you want to test the stream yourself, please stream from
> http://ipv6.lkml.org:8000/difm .
>

I have no problem to stream from there. kernel-source-2.4.19 here. several
tunnels in the middle and different brand of routers...
anyway Im farly sure that the xmms patch is not the problem. We have been
testing it for more than 6 months now (for inclusion in debian, we are
not the upstream) and yes we hit a similar problems with one icecast
server but at that time we didn't care too much since it was basically at
the first tests round. I will see if i can get it up and running again
(it is not under my control) and investigate a bit more into it.

Thanks
Fabio
