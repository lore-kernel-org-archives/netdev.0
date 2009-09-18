From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 22:27:29 -0700
Message-ID: <20090918052729.GB6455@kroah.com>
References: <20090916.204801.190052862.davem@davemloft.net> <C43529A246480145B0A6D0234BDB0F0DE8A1@MELANITE.micrel.com> <20090917.164952.33104590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Choi@Micrel.Com, netdev@vger.kernel.org,
	Charles.Li@Micrel.Com, Choi@kroah.com, jgarzik@redhat.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45737 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbZIRFeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 01:34:46 -0400
Content-Disposition: inline
In-Reply-To: <20090917.164952.33104590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2009 at 04:49:52PM -0700, David Miller wrote:
> From: "Choi, David" <David.Choi@Micrel.Com>
> Date: Thu, 17 Sep 2009 12:30:27 -0700
> 
> > --- linux-2.6.31-rc3/drivers/net/ks8851_mll.c.orig	2009-09-17
> > 10:18:56.000000000 -0700
> > +++ linux-2.6.31-rc3/drivers/net/ks8851_mll.c	2009-09-17
> > 10:09:37.000000000 -0700
> > @@ -21,8 +21,6 @@
> >   * KS8851 16bit MLL chip from Micrel Inc.
> 
> I can't use this patch or even test it, as your email client
> has corrupted it by, for example, breaking up long lines.

Yeah, that's why I had to post the original patch for David :(

I'm going to be away from email for the next 10 days due to conferences,
so hopefully David can fix the email issue so he can repost it
himself...

thanks,

greg k-h
