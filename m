From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC,PATCH] fastroute dead code...
Date: Fri, 30 Jul 2004 15:35:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730193515.GA11365@havoc.gtf.org>
References: <20040730060348.GA22854@havoc.gtf.org> <ea86ce220407301229522be64f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Mattox <tmattox@gmail.com>
Content-Disposition: inline
In-Reply-To: <ea86ce220407301229522be64f@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2004 at 03:29:25PM -0400, Tim Mattox wrote:
> I looked into fastroute about a year ago as well.  It's been used in
> some clusters
> AFAIK, but I'm not sure if it's still being actively used.  I was
> considering trying to
> use it myself in some cluster FNN research work I'm doing.  But that's probably
> still 6 months away if I get to it.  Since I'd be having to patch
> other things anyway,
> I have no qualms with it going away from mainline...  Especially with GigE so
> cheap today, and legacy PCI bandwidths so low, it's not particularly economical
> today to route through nodes in an HPC cluster that uses TCP/IP interconnect.
> 
> I don't know if the webserver/load balancing community would mind it going
> away though.


Well my main point is that the code _doesn't do anything_.

It is dead code, as-is, in the kernel.  It would require patches to
actually work at all.

It is impossible that fastrouting is being actively used, without patches.

	Jeff
