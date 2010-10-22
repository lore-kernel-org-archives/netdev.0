From: Mark Glassberg <vzeeaxwl@myfairpoint.net>
Subject: usbnet
Date: Fri, 22 Oct 2010 09:29:15 -0400
Message-ID: <20101022132915.GB2107@etch.localnet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail123c26.carrierzone.com ([64.29.152.133]:49672 "EHLO
	mail123c26.carrierzone.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755577Ab0JVOSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 10:18:21 -0400
Received: from localhost (pool-71-255-143-108.cncdnh.east.myfairpoint.net [71.255.143.108])
	(authenticated bits=0)
	by mail123c26.carrierzone.com (8.13.6/8.13.1) with ESMTP id o9MDTFsv019022
	for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 13:29:17 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure if this is the right place to ask but, if it is, I could
really use some help getting my 2Wire PC Ports (see below) to work
with linux.

Any assistance, including the proper address of the usbnet developers,
would be greatly appreciated.

----- Forwarded message from Ben Hutchings <ben@decadent.org.uk> -----

From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#600660: linux-2.6: Please revert patch for USB54Gs
	wireless device
To: Mark Glassberg <vzeeaxwl@myfairpoint.net>
Date: Thu, 21 Oct 2010 03:40:16 +0100
X-Mailer: Evolution 2.30.3 

On Wed, 2010-10-20 at 16:34 -0400, Mark Glassberg wrote:
> ... Part of my home network
> uses HomePNA (hpna) technology.  I'd like to be able to use it with our two
> laptops; and the 2Wire PC Port is a usb device that act like an hpna network
> interface card.  It works under Windows but there is still no linux driver.
> Unfortunately, I've never been able to get ndiswrapper to work with these
> devices either.  Any assistance would be greatly appreciated.

Try talking to the usbnet developers about this.  It might be possible
to handle it within one of the existing drivers.

David Brownell <dbrownell@users.sourceforge.net>
netdev@vger.kernel.org (mailing list)

Ben.

-- 
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.



----- End forwarded message -----
