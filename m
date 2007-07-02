From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Mon, 02 Jul 2007 08:25:32 -0400
Message-ID: <4688EEBC.5020209@garzik.org>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org>	<200706270154.16022.david-b@pacbell.net>	<20070627144416.GA28899@kroah.com> <877ippgq9x.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Brownell <david-b@pacbell.net>,
	netdev@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50950 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015AbXGBMZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:25:38 -0400
In-Reply-To: <877ippgq9x.fsf@p4.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
>>>>>> "Greg" == Greg KH <greg@kroah.com> writes:
> 
>  Greg> Yeah, this is the cdc_acm driver that is still in the USB drivers/
>  Greg> directory tree as it is a USB class driver that shows up as a tty device
>  Greg> to userspace.  It should not be moved to the networking list unless no
>  Greg> one minds that I never see any queries about it :)
> 
> Ok, here's an updated patch:
> 
> Questions regarding the USB network drivers should now go to netdev.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> Acked-by: David Brownell <dbrownell@users.sourceforge.net>

applied


