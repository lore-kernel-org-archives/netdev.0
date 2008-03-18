From: David Miller <davem@davemloft.net>
Subject: Re: [resend] [PATCH 2.6.25] BNX2X: prevent ethtool setting of port
 type
Date: Mon, 17 Mar 2008 22:51:35 -0700 (PDT)
Message-ID: <20080317.225135.120239252.davem@davemloft.net>
References: <1205765879.8232.387.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750763AbYCRFvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 01:51:20 -0400
In-Reply-To: <1205765879.8232.387.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Mon, 17 Mar 2008 16:57:59 +0200

> BNX2X: prevent ethtool setting of port type
> 
> On 10GBaseT boards setting the type to TP will cause the driver to try
> to configure 1GBaseT.
> Since there are currently no boards that support setting the of the port
> type, disable this for now.
> 
> Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>

Your patch is corrupt, your email client has chopped up long
lines.

Please correct this and resubmit.
