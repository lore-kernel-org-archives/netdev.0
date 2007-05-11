From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/13] Use menuconfig objects II - netdev/atm
Date: Fri, 11 May 2007 16:51:41 -0400
Message-ID: <4644D75D.1090407@garzik.org>
References: <200705110552.l4B5qvFr007816@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42256 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757310AbXEKUvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:51:44 -0400
In-Reply-To: <200705110552.l4B5qvFr007816@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> 
> Make a "menuconfig" out of the Kconfig objects "menu, ..., endmenu",
> so that the user can disable all the options in that menu at once
> instead of having to disable each option separately.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/atm/Kconfig |   32 +++++++++++++++++---------------
>  1 file changed, 17 insertions(+), 15 deletions(-)

Pattern match correction:

drivers/atm/* goes through DaveM.

	Jeff



