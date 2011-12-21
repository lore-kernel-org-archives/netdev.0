From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igb: Add support for byte queue limits.
Date: Wed, 21 Dec 2011 14:42:07 -0500 (EST)
Message-ID: <20111221.144207.1402252938319338463.davem@davemloft.net>
References: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab1LUTmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:42:10 -0500
In-Reply-To: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 16:18:15 +0100

> This adds support for byte queue limits (BQL)
> 
> Since this driver collects bytes count in 'bytecount' field, use it also
> in igb_tx_map()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Alexander Duyck <alexander.h.duyck@intel.com>

Intel folks, you got this?
