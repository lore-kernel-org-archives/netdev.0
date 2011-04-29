From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ftmac100: fix scheduling while atomic during PHY
 link status change
Date: Fri, 29 Apr 2011 12:31:32 -0700 (PDT)
Message-ID: <20110429.123132.245399312.davem@davemloft.net>
References: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ratbert@faraday-tech.com, ratbert.chuang@gmail.com,
	netdev@vger.kernel.org
To: adam.jaremko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932544Ab1D2TcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:32:05 -0400
In-Reply-To: <BANLkTi=gcFB4mbmWKu4neep77Jp8R4HWGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Jaremko <adam.jaremko@gmail.com>
Date: Tue, 26 Apr 2011 12:32:56 -0400

> @@ -801,7 +801,7 @@ static void ftmac100_mdio_write(struct net_device
> *netdev, int phy_id, int reg,

Your email client corrupted the patch, adding line breaks etc.

Please fix this problem, send a test email to yourself, try to apply
the patch you receive in that test email, and then when that is
working (and only then) resubmit this patch here so I can apply it.

Thanks.
