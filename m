From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [patch]support for USB autosuspend in the asix driver
Date: Tue, 14 Aug 2007 09:22:34 +0200
Message-ID: <200708140922.34927.oneukum@suse.de>
References: <200708031352.19419.oneukum@suse.de> <46C13546.8030508@pobox.com> <200708132222.13978.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:44599 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbXHNHWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 03:22:42 -0400
In-Reply-To: <200708132222.13978.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag 14 August 2007 schrieb David Brownell:
> On Monday 13 August 2007, Jeff Garzik wrote:
> > Oliver Neukum wrote:
> > > Hi,
> > > 
> > > this implements support for USB autosuspend in the asix USB ethernet
> > > driver.
> > > 
> > > 	Regards
> > > 		Oliver
> > > Signed-off-by: Oliver Neukum <oneukum@suse.de>
> > 
> > David, does this look OK to you?  I never saw much comment from anybody, 
> > and cannot really comment on the USB parts.
> 
> I didn't see anything obviously wrong.  I presume Oliver tested
> this with actual ASIX hardware ... assuming that, it's OK by me.

I've tested it. It works.

	Regards
		Oliver
