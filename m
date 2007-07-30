From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] forcedeth: mac address correct
Date: Mon, 30 Jul 2007 15:50:29 -0400
Message-ID: <46AE4105.7080602@garzik.org>
References: <46A96A78.1050008@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51920 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965487AbXG3Tuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:50:44 -0400
In-Reply-To: <46A96A78.1050008@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> Resending:
> 
> In older chipsets, the mac address was stored in reversed order.
> However, in newer chipsets, the mac address is in correct order. This
> patch takes those newer chipsets into account and does not rely on a
> special bit setup by BIOS'.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied


