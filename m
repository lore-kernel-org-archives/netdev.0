From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Initialize cnic status block during chip reset
Date: Fri, 25 Dec 2009 17:14:07 -0800 (PST)
Message-ID: <20091225.171407.71125891.davem@davemloft.net>
References: <1261576965.15524.42.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754482AbZLZBOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 20:14:05 -0500
In-Reply-To: <1261576965.15524.42.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 23 Dec 2009 16:02:45 +0200

> From: Michael Chan <mchan@broadcom.com>
> 
> When the device is reset during MTU change, ring size change, or self
> test, etc, the cnic status block needs to be properly initialized if
> cnic is registered.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
