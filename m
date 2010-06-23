From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cnic: Disable statistics initialization for
 eth clients that do not support statistics
Date: Wed, 23 Jun 2010 12:22:03 -0700 (PDT)
Message-ID: <20100623.122203.115921668.davem@davemloft.net>
References: <1277320179.5984.13.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33144
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751940Ab0FWTVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 15:21:51 -0400
In-Reply-To: <1277320179.5984.13.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 23 Jun 2010 22:09:39 +0300

> Disable statistics initialization for eth clients that do not support
>  statistics. This prevents memory corruption on bnx2x hw.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
