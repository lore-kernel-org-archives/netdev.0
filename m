From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] BNX2X: prevent ethtool from setting port type
Date: Sun, 23 Mar 2008 03:08:03 -0700 (PDT)
Message-ID: <20080323.030803.128054786.davem@davemloft.net>
References: <1206252306.13326.3.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34096
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755714AbYCWKHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:07:50 -0400
In-Reply-To: <1206252306.13326.3.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Sun, 23 Mar 2008 08:05:06 +0200

> BNX2X: prevent ethtool from setting port type
> 
> On 10GBaseT boards setting the type to TP will cause the driver to try
> to configure 1GBaseT.
> Since there are currently no boards that support setting of the port
> type, disable this for now.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Applied, thanks.
