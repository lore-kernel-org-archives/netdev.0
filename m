From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch]support for USB autosuspend in the asix driver
Date: Mon, 13 Aug 2007 22:22:13 -0700
Message-ID: <200708132222.13978.david-b@pacbell.net>
References: <200708031352.19419.oneukum@suse.de> <46C13546.8030508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.sbc.mail.re2.yahoo.com ([68.142.229.101]:27268 "HELO
	smtp104.sbc.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759453AbXHNGRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 02:17:38 -0400
In-Reply-To: <46C13546.8030508@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007, Jeff Garzik wrote:
> Oliver Neukum wrote:
> > Hi,
> > 
> > this implements support for USB autosuspend in the asix USB ethernet
> > driver.
> > 
> > 	Regards
> > 		Oliver
> > Signed-off-by: Oliver Neukum <oneukum@suse.de>
> 
> David, does this look OK to you?  I never saw much comment from anybody, 
> and cannot really comment on the USB parts.

I didn't see anything obviously wrong.  I presume Oliver tested
this with actual ASIX hardware ... assuming that, it's OK by me.

- Dave


> 
> 	Jeff
> 
> 
> 


