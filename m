From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] connector: Convert char *name to const char *name
Date: Wed, 23 Feb 2011 13:22:46 -0800
Message-ID: <20110223212246.GA23766@kroah.com>
References: <1298151834-13141-1-git-send-email-martinez.javier@gmail.com>
 <1298159129.7179.32.camel@Joe-Laptop>
 <20110220143259.GA19984@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org,
	"K. Y. Srinivasan" <ksrinivasan@novell.com>,
	netdev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:59304 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663Ab1BWVqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 16:46:12 -0500
Content-Disposition: inline
In-Reply-To: <20110220143259.GA19984@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 20, 2011 at 05:32:59PM +0300, Evgeniy Polyakov wrote:
> Hi Joe.
> 
> On Sat, Feb 19, 2011 at 03:45:29PM -0800, Joe Perches (joe@perches.com) wrote:
> > Allow more const declarations.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > 
> > ---
> > 
> > Better to change the declarations and uses as this argument
> > is not modified.
> 
> Looks good, thank you.
> Greg, please push it into your tree.
> 
> Acked-by: Evgeniy Polyakov <zbr@ioremap.net>

Now applied, thanks.

greg k-h
