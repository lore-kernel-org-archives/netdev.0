From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: phy: bcm7xxx: Misc cleanups
Date: Tue, 16 Feb 2016 14:58:30 -0500 (EST)
Message-ID: <20160216.145830.1323410620282819571.davem@davemloft.net>
References: <1454792977-7987-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474AbcBPT6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:58:32 -0500
In-Reply-To: <1454792977-7987-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  6 Feb 2016 13:09:35 -0800

> These two patches are cleanups to the BCM7xxx internal PHY driver:
> 
> - fix a constant name missing a X (as in BCM7XXX)
> - add a macro to reduce the amount of code duplication to add new entries

Series applied, thanks.
