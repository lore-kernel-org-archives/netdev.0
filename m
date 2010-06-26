From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/4] More sfc changes for 2.6.36
Date: Fri, 25 Jun 2010 21:08:53 -0700 (PDT)
Message-ID: <20100625.210853.214236525.davem@davemloft.net>
References: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894Ab0FZEIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 00:08:40 -0400
In-Reply-To: <1277485434.2094.13.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 25 Jun 2010 18:03:54 +0100

> Ben Hutchings (4):
>   sfc: Fix reading of inserted hash
>   sfc: Move siena_nic_data::ipv6_rss_key to efx_nic::rx_hash_key
>   sfc: Use Toeplitz IPv4 hash for RSS and hash insertion
>   sfc: Log clearer error messages for hardware monitor

All applied, thanks.
