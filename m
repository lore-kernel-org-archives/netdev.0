From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] Update in-kernel orinoco drivers to upstream current CVS
Date: Sun, 4 Jul 2004 12:01:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040704020106.GB25992@zax>
References: <1088795498.18039.25.camel@dcbw.boston.redhat.com> <40E5B6AD.6060904@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40E5B6AD.6060904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 02, 2004 at 03:25:33PM -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> >Hi,
> >
> >This patch is simply the fixed-up diff between the kernel's current
> >0.13e version and the upstream 0.15rc1+ version from savannah CVS.
> >0.15rc1 has been out for a couple months now and seems stable.
> >
> >The major benefits that this newer version brings are, of course, many
> >bugfixes, but best of all wireless scanning support for the Orinoco line
> >of cards.
> >
> >http://people.redhat.com/dcbw/linux-2.6.7-orinoco.patch.bz2
> >
> >Dan Williams
> >Red Hat, Inc.
> 
> 
> I'm desperately hoping that someone will split this up into multiple 
> patches...

Urg, yes.  I've dropped the ball badly on this.  I've done very, very
little work on the driver for well over a year now and the changes
have built up to a megapatch.  I really does need to be broken up, but
the chances of me finding the time and motivation to do so are not
looking good.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
