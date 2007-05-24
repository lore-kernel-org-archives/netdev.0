From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool: new ID to decode the registers of the 8168 (realtek)
Date: Thu, 24 May 2007 17:50:02 -0400
Message-ID: <4656088A.6030006@pobox.com>
References: <20070524200242.GA17722@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48405 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbXEXVuF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:50:05 -0400
In-Reply-To: <20070524200242.GA17722@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Tested with an Asrock 945G-DVI (LOM).
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  realtek.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)

applied

Also, I have really fallen off the ball when it comes to the r8169 
kernel driver.  My apologies.

Would you be kind enough to resend?  If there are important bug fixes 
that need to go into 2.6.22, that are safe enough to put in at this late 
date, please split those off from other improvements.

	Jeff



