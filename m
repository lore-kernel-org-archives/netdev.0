From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 2/8] net: phy: Check fixup lists in
 get_phy_device()
Date: Sun, 03 May 2015 22:02:51 -0400 (EDT)
Message-ID: <20150503.220251.2176215566157696249.davem@davemloft.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
	<1430359064-23454-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbEDCCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:02:54 -0400
In-Reply-To: <1430359064-23454-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 29 Apr 2015 18:57:38 -0700

> MDIO-connected Ethernet switches will typicall appear as regular

Typo "typically".
