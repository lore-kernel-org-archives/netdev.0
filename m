From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/13] Use menuconfig objects: PHY
Date: Fri, 11 May 2007 16:57:39 -0400
Message-ID: <4644D8C3.9030503@garzik.org>
References: <200705110552.l4B5qt1l007807@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42337 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760169AbXEKU5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:57:41 -0400
In-Reply-To: <200705110552.l4B5qt1l007807@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> 
> Use menuconfigs instead of menus, so the whole menu can be disabled at once
> instead of going through all options.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/phy/Kconfig |   22 ++++++----------------
>  1 file changed, 6 insertions(+), 16 deletions(-)

applied 6-7


