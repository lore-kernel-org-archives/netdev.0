From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] tulip, kernel 2.4.26-rc2, 3rd try
Date: 11 Apr 2004 15:37:15 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081712235.1040.371.camel@jzny.localdomain>
References: <Pine.LNX.4.43.0404091631060.19041-100000@skyhawk.ecc.engr.uky.edu>
	 <40770EA3.6040102@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timothy I Mattox <tmattox@engr.uky.edu>, tulip-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, Jay Estabrook <Jay.Estabrook@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40770EA3.6040102@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-04-09 at 16:59, Jeff Garzik wrote:

> It's not ready to turn them all on yet, unfortunately.  Tulip driver 
> desperately wants ethtool support, too.
> 
> Dr. Jamal Salim ported the phy code from a recent version of Donald 
> Becker's tulip.c to upstream...  that's what we really want to merge. 
> Jay Estabrook updated this while pursuing tulip problems on alpha.  This 
> patch needs testing and merging...
> 

The code Jeff mentions is about a year old - so needs updates.
I will send anyone who will ensure that this goes in cleanly one or two
of my NICs + the code since i dont have much time to allocate to this
lately. There were bits in there as well to fix SYM phys in addition to
the netif_carrier_xxxx stuff. You want the NICs you have to promise to
make sure both work. Send me private email.

cheers,
jamal
