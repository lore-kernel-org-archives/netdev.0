From: Jeff Garzik <jeff@garzik.org>
Subject: Re: driver support for Chelsio T210 10Gb ethernet in 2.6.x
Date: Tue, 14 Nov 2006 17:57:27 -0500
Message-ID: <455A49D7.4050106@garzik.org>
References: <Pine.LNX.4.64.0611131408010.32659@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54482 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966440AbWKNW5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 17:57:30 -0500
To: Chris Stromsoe <cbs@cts.ucla.edu>
In-Reply-To: <Pine.LNX.4.64.0611131408010.32659@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Stromsoe wrote:
> The in-kernel Chelsio cxgb driver in 2.6.19-rc5 is version 2.1.1 and 
> only supports the N110 and N210 10Gb ethernet boards.  The current 
> driver available from Chelsio[1] is 2.1.4a and supports the T110 and 
> T210 series boards, but is only available against 2.6.16.  Any chance of 
> an update to the in-kernel driver for 2.6.20 to support the T* series 
> cards?
> 
> -Chris
> 
> 1. http://service.chelsio.com/drivers/linux/n210/cxgb-2.1.4a.tar.gz

A bit of history:  this driver was merged in March 2005 (submitted by 
Chelsio), updated once in June 2005, and then the maintainers completely 
disappeared.

So, you get what you get...  if someone wants to dig through the updated 
cxgb driver and merge it with the kernel and test it... great.  But at 
this point it is abandonware.

	Jeff


