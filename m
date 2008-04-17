From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] PHY: add BCM5464 support to broadcom PHY driver
Date: Wed, 16 Apr 2008 20:54:26 -0400
Message-ID: <48069FC2.60900@garzik.org>
References: <1207752406-4624-1-git-send-email-paul.gortmaker@windriver.com> <20080409150412.GA4912@windriver.com> <48007C3F.5050505@garzik.org> <20080415033538.GA14095@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57532 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbYDQAy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 20:54:29 -0400
In-Reply-To: <20080415033538.GA14095@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> In message: Re: [PATCH] PHY: add BCM5464 support to broadcom PHY driver
> on 12/04/2008 Jeff Garzik wrote:
> 
>> doesn't seem to apply...  can you please regenerate against  
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.26.git ?
> 
> No problem.  The already queued BCM 5481 and this overlapped. It should
> be good to go now.
> 
> P.
> ---
> 
>  From f01cb20f9d5c4f6cc9040c0a5ec13409396e64d5 Mon Sep 17 00:00:00 2001
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 14 Apr 2008 23:27:12 -0400
> Subject: [PATCH] PHY: add BCM5464 support to broadcom PHY driver
> 
> The BCM5464 can be used with the current broadcom PHY driver
> by just adding the appropriate chip ID and using the existing
> support within.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  drivers/net/phy/broadcom.c |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+), 0 deletions(-)

applied


