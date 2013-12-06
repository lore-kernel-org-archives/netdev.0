From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] xhci: Regression fix for 3.13.
Date: Fri, 06 Dec 2013 12:29:45 -0500 (EST)
Message-ID: <20131206.122945.132454720743612382.davem@davemloft.net>
References: <20131202214205.GA26175@kroah.com>
	<52A166CB.4020508@pobox.com>
	<20131206170325.GA14254@xanatos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlord@pobox.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: sarah.a.sharp@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756486Ab3LFR3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:29:47 -0500
In-Reply-To: <20131206170325.GA14254@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sarah, calm down.

Let Greg merge the XHCI fix and let's have people test it.

The whole holdup is because the USB subsystem is taking forever
to merge the XHCI patch.

I would have merged it in 24-48 hours if it were my subsystem. :)
