From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] fix arm/etherh.c allocation
Date: Thu, 22 Apr 2004 08:33:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040422083342.A31406@flint.arm.linux.org.uk>
References: <200404202049.09130.daniel.ritz@gmx.ch> <40873BEA.1040208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel.ritz@gmx.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40873BEA.1040208@pobox.com>; from jgarzik@pobox.com on Wed, Apr 21, 2004 at 11:28:42PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 21, 2004 at 11:28:42PM -0400, Jeff Garzik wrote:
> Daniel Ritz wrote:
> > --- 1.23/drivers/net/arm/etherh.c	Wed Apr 14 12:23:55 2004
> > +++ edited/etherh.c	Tue Apr 20 20:39:04 2004
> 
> 
> can one of you resend something that applies with 'patch -sp1'?

I've noticed this as well - I just end up fixing the patch headers
manually.  It's a BK bug unfortunately - if you provide a directory
for bk diffs, it messes up like above, but if you give explicit files
it doesn't.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
