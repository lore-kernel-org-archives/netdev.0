From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.28-rc2] at91_ether:  request/free GPIO for PHY interrupt
Date: Fri, 31 Oct 2008 00:48:37 -0400
Message-ID: <490A8E25.2090905@pobox.com>
References: <200810271411.34492.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Victor <linux@maxim.org.za>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54167 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbYJaEsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:48:43 -0400
In-Reply-To: <200810271411.34492.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: David Brownell <dbrownell@users.sourceforge.net>
> 
> When the at91_ether driver is using a GPIO for its PHY interrupt,
> be sure to request (and later, if needed, free) that GPIO.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> ---
>  drivers/net/arm/at91_ether.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)

applied


