From: Timothy I Mattox <tmattox@engr.uky.edu>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 2nd try
Date: Fri, 9 Apr 2004 15:43:16 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.43.0404091538000.19041-100000@skyhawk.ecc.engr.uky.edu>
References: <4076FA7F.7020801@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: tulip-devel@lists.sourceforge.net, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4076FA7F.7020801@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


OK, testing now...  I had the netif_carrier_xxx code commented out
from seeing them commented out in the tulip_timer routine just a few
lines above in the comet_timer() routine.

On Fri, 9 Apr 2004, Jeff Garzik wrote:
> Looks OK, but can you test without netif_carrier_xxx commented out?
>
> I would prefer to leave those active.
>
> 	Jeff

-- 
Tim Mattox - tmattox@engr.uky.edu - http://homepage.mac.com/tmattox/
    http://aggregate.org/KAOS/ - http://advogato.org/person/tmattox/
