From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: Re: [PATCH net-next] ethtool: Add 20G bit definitions
Date: Mon, 9 May 2011 13:16:57 +0300
Message-ID: <1304936217.32472.10.camel@lb-tlvb-dmitry>
References: <1304407809.2518.1.camel@lb-tlvb-dmitry>
 <20110508.154312.229736305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4493 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114Ab1EIKRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 06:17:14 -0400
In-Reply-To: <20110508.154312.229736305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-05-08 at 15:43 -0700, David Miller wrote:
> From: "Yaniv Rosner" <yanivr@broadcom.com>
> Date: Tue, 3 May 2011 10:30:08 +0300
> 
> > Add 20G supported and advertising bit definitions.
> > 20G will be supported with the 57840 chips.
> > 
> > 
> > Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> Applied to net-next-2.6, thanks.
> 
Ben,
Please note that I haven't added new definition for 20000 link speed because my understanding is that it no longer required.
Let me know if you think it is required, mainly for the speed extension in the ethtool application.

Yaniv


