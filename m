From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 3c509: convert to isa_driver and pnp_driver v6
Date: Wed, 26 Mar 2008 00:35:53 -0400
Message-ID: <47E9D2A9.7040107@garzik.org>
References: <200803071746.49554.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34224 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbYCZEf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:35:57 -0400
In-Reply-To: <200803071746.49554.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ondrej Zary wrote:
> Hello,
> this patch converts 3c509 driver to isa_driver and pnp_driver. The result is 
> that autoloading using udev and hibernation works with ISA PnP cards. It also 
> adds hibernation support for non-PnP ISA cards.
> 
> xcvr module parameter was removed as its value was not used.
> 
> Tested using 3 ISA cards in various combinations of PnP and non-PnP modes. 
> EISA and MCA only compile-tested.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> 

ACK, but your patch is word-wrapped and cannot be applied


