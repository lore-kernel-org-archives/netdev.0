From: Jeff Garzik <jeff@garzik.org>
Subject: Re: IC Plus Corp IC Plus IP1000
Date: Tue, 12 Jun 2007 22:21:02 -0400
Message-ID: <466F548E.9010807@garzik.org>
References: <46599FB9.602@udgaard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-10; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Rasmussen <plr@udgaard.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60150 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbXFMCVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 22:21:05 -0400
In-Reply-To: <46599FB9.602@udgaard.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Rasmussen wrote:
> I am not on this list, but found this address on:   
> http://linux-net.osdl.org/index.php/Mailing_Lists.
> 
> My question is regarding the ethernet controller (from lspci):
> 
> Sundance Technology Inc / IC Plus Corp IC Plus IP1000 Family Gigabit 
> Ethernet (rev 41)
> 
> that seems to have a driver for it published on:
> 
> http://www.icplus.com.tw/driver-pp-IP1000A.html
> 
> Unfortunately I am not able to build it as described.
> 
> I wonder if it at some time will be included in the standard Linux kernel?
> I am of course interested because my main board has it built in, so I 
> would be willing to test it.

Use the 'sundance' driver that's been in the kernel for quite a while.

	Jeff



