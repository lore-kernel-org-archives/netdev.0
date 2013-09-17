From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-09-17
Date: Mon, 16 Sep 2013 21:44:26 -0400 (EDT)
Message-ID: <20130916.214426.2179838295712589799.davem@davemloft.net>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3IQBo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:44:27 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Sep 2013 01:10:11 +0100

>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.12
 ...
> Some bug fixes and future-proofing for the recently added SFC9120
> support:
> 
> 1. Minimal support for the 40G configuration.
> 2. Disable the incomplete PTP/hardware timestamping support.
> 3. Reset MAC stats properly after a firmware upgrade.
> 4. Re-check the datapath firmware capabilities after the controller is
> reset.

Pulled, thanks Ben.
