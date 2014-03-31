From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: document sysfs entries
Date: Mon, 31 Mar 2014 16:11:00 -0400 (EDT)
Message-ID: <20140331.161100.642930165214073947.davem@davemloft.net>
References: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaCaULC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:11:02 -0400
In-Reply-To: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 28 Mar 2014 14:25:56 -0700

> This patchset attempts to document the basic set of sysfs entries that are
> exposed by netdevices in /sys/class/net/<iface>/
> 
> I did not go before the pre-git era, so the oldest entries are marked with
> the 2.6.12 kernel version and dated of April 2005.
> 
> Future patches will document the queues/ and statistics/ directories as well.

Series applied, thanks for doing this Florian.
