From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] sfc: SFN8000 support improvements
Date: Fri, 12 Aug 2016 20:51:19 -0700 (PDT)
Message-ID: <20160812.205119.1620323708766243315.davem@davemloft.net>
References: <1137d3d8-0b1b-d5f5-149a-1771bbac7aa6@solarflare.com>
	<78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbcHMDvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 23:51:20 -0400
In-Reply-To: <78a8505b-8c63-b879-2cd2-d78d9890aa6c@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Thu, 11 Aug 2016 12:59:20 +0100

> This series improves support for the recently released SFN8000 series
> of adapters. Specifically, it retrieves interrupt moderation timer
> settings directly from the adapter and uses those settings. It also
> uses a new event queue initialisation interface, allowing specification
> of a performance objective rather than enabling individual flags.

Series applied, thanks.
