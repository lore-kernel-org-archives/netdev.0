From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH] sis900.c net poll support
Date: Wed, 5 Jan 2005 15:59:16 +0100
Message-ID: <20050105145916.GA31207@picchio.gall.it>
References: <1104921127.5729.17.camel@athlon64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Brancaleoni Matteo <mbrancaleoni@tiscali.it>
Content-Disposition: inline
In-Reply-To: <1104921127.5729.17.camel@athlon64>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks, it was on my TODO list and now I can just remove the entry :-)
I'll try to integrate your patch in the next sis900 update.

Bye.

On Wed, Jan 05, 2005 at 11:32:07AM +0100, Brancaleoni Matteo wrote:
> Hi.
> 
> I was in need to use netconsole to trace some lock
> of my sata disk, but my onboard network card (sis900)
> seems doesn't support net poll.
> So searching the web I found out an old patch for enabling
> in under 2.4, and ported it to 2.6.10 (looking
> also into 2.6.x device drivers already working)
> 
> Seems to be ok, netconsole works without issues.
> Hope that's ok and can be useful.
> 
> Matteo Brancaleoni.

> --- linux-2.6.10/drivers/net/sis900.orig	2005-01-05 09:55:46.000000000 +0100
> +++ linux-2.6.10/drivers/net/sis900.c	2005-01-05 10:09:04.000000000 +0100

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
