From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy: Add MOXA MDIO driver
Date: Thu, 07 Nov 2013 15:37:29 -0500 (EST)
Message-ID: <20131107.153729.485901803954655270.davem@davemloft.net>
References: <1383317673-14704-1-git-send-email-jonas.jensen@gmail.com>
	<1383666901-22354-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, grant.likely@secretlab.ca
To: jonas.jensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336Ab3KGUhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 15:37:31 -0500
In-Reply-To: <1383666901-22354-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Tue,  5 Nov 2013 16:55:01 +0100

> The MOXA UC-711X hardware(s) has an ethernet controller that seem
> to be developed internally. The IC used is "RTL8201CP".
> 
> This patch adds an MDIO driver which handles the MII bus.
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied, thanks Jonas.
