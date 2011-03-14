From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: changes for BE3 native mode
 support
Date: Mon, 14 Mar 2011 15:17:23 -0700 (PDT)
Message-ID: <20110314.151723.02279298.davem@davemloft.net>
References: <9260707d-e902-4497-a550-a5125c46e2c4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53789
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932188Ab1CNWQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:16:45 -0400
In-Reply-To: <9260707d-e902-4497-a550-a5125c46e2c4@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 11 Mar 2011 18:19:26 +0530

>  So far be2net has been using BE3 in legacy mode. It now checks for native
>  mode capability and if available it sets it. In native mode, the RX_COMPL
>  structure is different from that in legacy mode.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
