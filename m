From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] Remove unused kernel config option DLCI_COUNT
Date: Tue, 06 Feb 2007 19:15:57 -0500
Message-ID: <45C91A3D.7070107@garzik.org>
References: <200702060032.l160W9s8004643@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rpjday@mindspring.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56628 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030299AbXBGAQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:16:03 -0500
In-Reply-To: <200702060032.l160W9s8004643@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Robert P. J. Day" <rpjday@mindspring.com>
> 
> Remove the unused kernel config option DLCI_COUNT.
> 
> Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Krzysztof Halasa {khc@pm.waw.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/wan/Kconfig |   11 -----------
>  1 file changed, 11 deletions(-)

applied


