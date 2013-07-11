From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] drivers: net: phy: at803x: Add missing mdio device
 id
Date: Thu, 11 Jul 2013 11:54:35 -0700 (PDT)
Message-ID: <20130711.115435.1082938863199252429.davem@davemloft.net>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: helmut.schaa@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756497Ab3GKSyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:54:36 -0400
In-Reply-To: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helmut Schaa <helmut.schaa@googlemail.com>
Date: Thu, 11 Jul 2013 13:57:34 +0200

> at803x supports Atheros 8030, 8031 and 8035 PHYs. 8031 was missing from
> the mdio device id table.
> 
> Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>

Applied.
