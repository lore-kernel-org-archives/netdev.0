From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: Adding Unisys virtnic.c to the Network Tree
Date: Tue, 16 Dec 2014 16:13:54 -0500
Message-ID: <20141216211354.GB22253@gospo>
References: <5490976C.20409@redhat.com>
 <54909B71.10609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.romer@unisys.com, dzickus@redhat.com, prarit@redhat.com,
	Bruce.Vessey@unisys.com, sparmaintainer@unisys.com
To: Erik Arfvidson <earfvids@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39420 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaLPVN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 16:13:59 -0500
Content-Disposition: inline
In-Reply-To: <54909B71.10609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 03:52:01PM -0500, Erik Arfvidson wrote:
> Hi Dave,
> 
> I'm a partner engineer at Red Hat working for Unisys. Currently most of our
> driver for our system reside in the staging tree Maintained by Greg KH. It
> was suggested by one of the engineers at Red Hat Don Zickus that in order to
> accelerate the process of moving the remaining drivers we pushed directly to
> their specific system in the Linux Kernel. Currently virtnic which is our
> Virtual Network driver resides internally at Unisys and dependencies are in
> the staging tree(drivers/staging/unisys/). So would you be willing to take a
> look at our Network driver in order to add it to your Network tree?

Erik,

I realize I'm not Dave, but I thought I could respond anyway.  :)

I suspect that if you posted the driver to this list, more eyes than
just Dave would be willing to take a look and provide inline feedback.

-andy
