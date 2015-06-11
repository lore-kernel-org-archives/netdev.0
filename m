From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: phy: broadcom: define pseudo-PHY
 address
Date: Wed, 10 Jun 2015 23:34:29 -0700 (PDT)
Message-ID: <20150610.233429.763508268033535865.davem@davemloft.net>
References: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, zajec5@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbbFKGea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:34:30 -0400
In-Reply-To: <1433984881-28781-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 10 Jun 2015 18:07:56 -0700

> This patch series converts existing in-tree users of the Broadcom pseudo-PHY
> address (30) used to configure MDIO-connected switches to share a constant in a
> shared header files.

This looks fine, series applied, thanks.
