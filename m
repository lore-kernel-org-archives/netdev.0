From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/13] Use menuconfig objects II - netdev/pcmcia
Date: Fri, 11 May 2007 16:58:05 -0400
Message-ID: <4644D8DD.6090701@garzik.org>
References: <200705110552.l4B5qw0X007819@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de,
	linux@dominikbrodowski.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760363AbXEKU6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:58:07 -0400
In-Reply-To: <200705110552.l4B5qw0X007819@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> 
> Change Kconfig objects from "menu, config" into "menuconfig" so
> that the user can disable the whole feature without having to
> enter the menu first.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/pcmcia/Kconfig |   23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)

applied 10-13


