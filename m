From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/4] net: phy: bcm7xxx 40nm PHY fixes
Date: Tue, 16 Feb 2016 14:56:02 -0500 (EST)
Message-ID: <20160216.145602.1328153421454623097.davem@davemloft.net>
References: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, florian.fainelli@broadcom.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbcBPT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:56:05 -0500
In-Reply-To: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  6 Feb 2016 12:58:47 -0800

> Here is a collection of fixes for the 40nm Ethernet PHY supported
> by the 7xxx PHY driver, please also queue these fixes for stable.
> 
> Changes in v2:
> 
> - dropped the cleanup patch, not appropriate
> - added another patch removing bogus wildcard entries

Series applied, thanks Florian.
