From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: NETIF_F_HW_CSUM does not imply FCoE
 CRC offload
Date: Wed, 27 Oct 2010 11:01:06 -0700 (PDT)
Message-ID: <20101027.110106.115947932.davem@davemloft.net>
References: <1287758306.2316.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zou@intel.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab0J0SAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:00:42 -0400
In-Reply-To: <1287758306.2316.35.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 22 Oct 2010 15:38:26 +0100

> NETIF_F_HW_CSUM indicates the ability to update an TCP/IP-style 16-bit
> checksum with the checksum of an arbitrary part of the packet data,
> whereas the FCoE CRC is something entirely different.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Cc: stable@kernel.org [2.6.32+]

Applied, thanks a lot Ben.
