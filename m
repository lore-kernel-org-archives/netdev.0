From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] be2net:Changes to update ethtool
 get_settings function to return appropriate values.
Date: Wed, 28 Oct 2009 04:15:29 -0700 (PDT)
Message-ID: <20091028.041529.231815577.davem@davemloft.net>
References: <20091022132949.GA23701@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37403
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbZJ1LPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 07:15:08 -0400
In-Reply-To: <20091022132949.GA23701@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Thu, 22 Oct 2009 19:00:00 +0530

> Update ethtool get_settings function to:
> - get current link speed settings from controller
> - get port transceiver type from controller
> - fill appropriate values for supported, phy_address
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied, thanks.
