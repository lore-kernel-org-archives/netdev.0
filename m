From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2 1/4]: Don't apply CRC PHY workaround to 5709.
Date: Mon, 08 Jan 2007 19:56:43 -0800 (PST)
Message-ID: <20070108.195643.67561534.davem@davemloft.net>
References: <1168300581.4430.7.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750721AbXAID4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 22:56:43 -0500
To: mchan@broadcom.com
In-Reply-To: <1168300581.4430.7.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 08 Jan 2007 15:56:21 -0800

> [BNX2]: Don't apply CRC PHY workaround to 5709.
> 
> The workaround is only needed on 5706/5708 and cannot be applied on
> 5709.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
