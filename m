From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] tc35815: Statistics cleanup
Date: Sat, 12 Apr 2008 05:00:49 -0400
Message-ID: <48007A41.2000803@garzik.org>
References: <20080411.002412.03977557.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59324 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756287AbYDLJAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:00:55 -0400
In-Reply-To: <20080411.002412.03977557.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> Use struct net_device_stats embedded in struct net_device.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
>  drivers/net/tc35815.c |   61 +++++++++++++++++++++++++------------------------
>  1 files changed, 31 insertions(+), 30 deletions(-)

applied 1-6


