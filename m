From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 089/181] Blackfin: on-chip ethernet MAC controller driver
Date: Sun, 06 May 2007 20:20:40 -0400
Message-ID: <463E70D8.6000403@garzik.org>
References: <200705062150.l46LoVWQ024648@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, bryan.wu@analog.com,
	netdev <netdev@vger.kernel.org>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41582 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752770AbXEGAUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 20:20:43 -0400
In-Reply-To: <200705062150.l46LoVWQ024648@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Wu, Bryan" <bryan.wu@analog.com>
> 
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig    |   44 +
>  drivers/net/Makefile   |    1 
>  drivers/net/bfin_mac.c |  981 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  147 +++++
>  4 files changed, 1173 insertions(+)

WTF?

Why are new network drivers not going to me, netdev, and/or DaveM?

Something is really broken here.  What is it?

I NAK this driver purely on the basis of lack of review.

	Jeff



