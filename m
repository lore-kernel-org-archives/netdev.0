From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 3/3] phylib: Add rudimentary Generic 10G support
Date: Thu, 13 Oct 2011 16:51:35 +0100
Message-ID: <1318521095.2745.11.camel@bwh-desktop>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com>
	 <1318516660-25452-4-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17878 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab1JMPvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 11:51:38 -0400
In-Reply-To: <1318516660-25452-4-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-13 at 09:37 -0500, Andy Fleming wrote:
> This is mostly taken from mdio.c, and modified to work under phylib.
> 
> However, the support is skewed toward 10GBaseT, as that is the only
> PHY available to me at this time.
[...]

Is it really necessary to have 2 copies of this code?

This one doesn't even look usable.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
