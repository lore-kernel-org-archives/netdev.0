From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] sfc: Bowdlerise PTP MCDI errors
Date: Wed, 13 May 2015 15:12:08 -0400 (EDT)
Message-ID: <20150513.151208.1836785997721760252.davem@davemloft.net>
References: <5551EC0F.2080607@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933522AbbEMTMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:12:10 -0400
In-Reply-To: <5551EC0F.2080607@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 12 May 2015 13:03:27 +0100

> When the NIC doesn't support PTP, probe-time MCDI commands fail in
> predictable ways.  Instead of logging cryptic MCDI errors, just log that
> PTP isn't supported.
> 
> v2: Hopefully stop Thunderbird mangling the patches.

Series applied, thanks.
