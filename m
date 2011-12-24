From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rfs: better sizing of dev_flow_table
Date: Sat, 24 Dec 2011 16:19:05 -0500 (EST)
Message-ID: <20111224.161905.847705637323458435.davem@davemloft.net>
References: <1324652031.2223.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<C6E2C6E1-A4DA-45F8-A94F-D3B78AFA018F@gmail.com>
	<1324745809.2915.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, chavey@google.com,
	xi.wang@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab1LXVTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 16:19:09 -0500
In-Reply-To: <1324745809.2915.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 24 Dec 2011 17:56:49 +0100

> Aim of this patch is to provide full range of rps_flow_cnt on 64bit arches.
> 
> Theorical limit on number of flows is 2^32
> 
> Fix some buggy RPS/RFS macros as well.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>
> CC: Xi Wang <xi.wang@gmail.com>
> CC: Laurent Chavey <chavey@google.com>

Applied, thanks.
