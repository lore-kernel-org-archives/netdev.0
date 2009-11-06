From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: tx_bytes might be slightly wrong
Date: Thu, 05 Nov 2009 21:08:32 -0800 (PST)
Message-ID: <20091105.210832.76416142.davem@davemloft.net>
References: <4AF236D1.7020006@candelatech.com>
	<4AF260BB.6070607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52511
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751538AbZKFFIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 00:08:07 -0500
In-Reply-To: <4AF260BB.6070607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Nov 2009 06:20:59 +0100

> [PATCH net-next-2.6] pktgen: tx_bytes might be slightly wrong
> 
> cur_pkt_size can be changed in proc fs while pktgen is running,
> we better use a private field to get precise tx-bytes counter.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6
