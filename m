From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: Remove workaround for chipset quirk
Date: Wed, 03 Sep 2008 09:26:48 -0400
Message-ID: <48BE9098.2050603@garzik.org>
References: <> <1219899450-7098-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Brown <mbrown@fensystems.co.uk>
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46142 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbYICN0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:26:52 -0400
In-Reply-To: <1219899450-7098-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> Remove chipset-specific quirk workaround; the workaround caused
> unrecoverable DMA lockups when the driver was loaded following a
> PXE boot.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off-by: Michael Brown <mbrown@fensystems.co.uk>
> ---
>  drivers/net/netxen/netxen_nic_main.c |   10 ----------
>  1 files changed, 0 insertions(+), 10 deletions(-)

applied


