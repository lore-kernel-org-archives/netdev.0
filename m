From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 08:12:03 -0700
Message-ID: <20070627151203.41512235546@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org>
 <200706270154.16022.david-b@pacbell.net>
 <20070627144416.GA28899@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, netdev@vger.kernel.org, jeff@garzik.org,
	jacmet@sunsite.dk
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.sbc.mail.mud.yahoo.com ([68.142.198.203]:41722 "HELO
	smtp104.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751883AbXF0PMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 11:12:31 -0400
In-Reply-To: <20070627144416.GA28899@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > > @@ -3610,15 +3610,14 @@
> > > >  USB CDC ETHERNET DRIVER
> > > >  P:	Greg Kroah-Hartman
> > 
> > I think that may refer to the old cdc ethernet driver
> > though ... Greg?  The new one, in the usbnet framework,
> > is a very different beast...
>
> Yeah, this is the cdc_acm driver that is still in the USB drivers/
> directory tree as it is a USB class driver that shows up as a tty device
> to userspace.  It should not be moved to the networking list unless no
> one minds that I never see any queries about it :)

Then it should say "CDC ACM" not "CDC ETHERNET" ... ;)

- Dave

