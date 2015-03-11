From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: dsa: support PHY reads/writes
 diversion
Date: Wed, 11 Mar 2015 17:56:57 -0400 (EDT)
Message-ID: <20150311.175657.1620941116448860241.davem@davemloft.net>
References: <1426031833-5113-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbbCKV47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:56:59 -0400
In-Reply-To: <1426031833-5113-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 10 Mar 2015 16:57:10 -0700

> This patch series completes the PHY reads/writes diversion when we
> need to use the slave MII bus provided by DSA and the underlying
> switch drivers to implement the real PHY reads and writes. This is
> particularly useful when they are conflicting MDIO bus addresses as
> in the case of multiple Broadcom switches connected to each other
> (internal and external, or just external).

Series applied, thanks Florian.
