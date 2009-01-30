From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
 up
Date: Fri, 30 Jan 2009 13:45:50 -0800 (PST)
Message-ID: <20090130.134550.81676804.davem@davemloft.net>
References: <20090127132718.GA10001@x200.localdomain>
	<20090129.170043.180340152.davem@davemloft.net>
	<20090130115907.GA22534@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752625AbZA3Vpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 16:45:52 -0500
In-Reply-To: <20090130115907.GA22534@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 30 Jan 2009 14:59:07 +0300

> On Thu, Jan 29, 2009 at 05:00:43PM -0800, David Miller wrote:
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > Date: Tue, 27 Jan 2009 16:27:18 +0300
> > 
> > > [PATCH] sky2: fix hard hang with netconsoling and iface going up
> > > 
> > > Printing anything over netconsole before hw is up and running is,
> > > of course, not going to work.
> > > 
> > > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > 
> > Alexey, can you get this tested by the reporter to make sure
> > it really fixes the hang?
> 
> I'm the reporter and tester and using this patch successfully. :-)

Then you give me no choice, I have to apply this patch :-)

Thanks!
