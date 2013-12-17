From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-12-16
Date: Tue, 17 Dec 2013 17:08:44 -0500 (EST)
Message-ID: <20131217.170844.558302251215177132.davem@davemloft.net>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49460 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3LQWIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:08:46 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 16 Dec 2013 21:29:10 +0000

> Miscellaneous changes for 3.14:
> 
> 1. Add more information to some WARN messages.
> 2. Refactor pushing of RSS configuration, from Andrew Rybchenko.
> 3. Refactor handling of automatic (device address list) vs manual (RX
> NFC) MAC filters.
> 4. Implement clearing of manual RX filters on EF10 when ntuple offload
> is disabled.
> 5. Remove definitions that are unused since the RX buffer allocation
> changes, from Andrew Rybchenko.
> 6. Improve naming of some statistics, from Shradha Shah.
> 7. Add statistics for PTP support code.
> 8. Fix insertion of RX drop filters on EF10.

Pulled, thanks Ben.
