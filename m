From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] SAA9730: Remove driver
Date: Fri, 11 Jul 2008 01:26:42 -0400
Message-ID: <4876EF12.5020207@garzik.org>
References: <20080709113843.GA28319@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35352 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbYGKF0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:26:46 -0400
In-Reply-To: <20080709113843.GA28319@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Baechle wrote:
> The only user of the board, the extremly dated and rare MIPS Atlas board,
> has been removed, so this driver can go, too.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> ---
> Well, Atlas will be removed for 2.6.27 ...
> 
>  drivers/net/Kconfig   |    9 
>  drivers/net/Makefile  |    1 
>  drivers/net/saa9730.c | 1139 --------------------------------------------------
>  drivers/net/saa9730.h |  384 ----------------
>  4 files changed, 1533 deletions(-)

applied


