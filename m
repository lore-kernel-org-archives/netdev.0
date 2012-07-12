From: Greg KH <gregkh@linuxfoundation.org>
Subject: Apple Thunderbolt Ethernet device support
Date: Thu, 12 Jul 2012 13:21:31 -0700
Message-ID: <20120712202131.GA26436@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38407 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932734Ab2GLUVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 16:21:36 -0400
Received: by pbbrp8 with SMTP id rp8so4233474pbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 13:21:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have an Apple Thunderbolt Ethernet device here, and running 3.5-rc6 it
isn't detected.  It has PCI id 14e4:1682, which seems like it should be
supported by the tg3 driver.  Any hints?

I guess I could just go and add the device id to the driver and see what
happens...

thanks,

greg k-h
