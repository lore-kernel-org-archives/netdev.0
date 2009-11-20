From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: Re: [net-next-2.6 PATCH] be2net:Patch to flash redboot section
 while firmware update.
Date: Fri, 20 Nov 2009 15:26:18 +0530
Message-ID: <20091120095617.GA29364@serverengines.com>
References: <20091119084829.GA19247@serverengines.com>
 <20091119.122356.62955207.davem@davemloft.net>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:27947 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751558AbZKTJ4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 04:56:11 -0500
Content-Disposition: inline
In-Reply-To: <20091119.122356.62955207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
   This is the primary boot loader program for the firmware. It is a separate
section in the firmware image.

- Sarvesh
On 19/11/09 12:23 -0800, David Miller wrote:
> From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> Date: Thu, 19 Nov 2009 14:18:43 +0530
> 
> > Please apply patch to update redboot section while firmware update. Code
> > checks if section needs to be updated before actually doing it.
> > 
> > Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
> 
> What is this redboot section all about?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
