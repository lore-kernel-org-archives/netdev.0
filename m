From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix bnx2x_storm_stats_update() on big endian
Date: Mon, 13 Feb 2012 16:02:17 -0500 (EST)
Message-ID: <20120213.160217.510408841852095863.davem@davemloft.net>
References: <1329150192.2494.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com,
	mchan@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758107Ab2BMVCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:02:21 -0500
In-Reply-To: <1329150192.2494.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Feb 2012 17:23:12 +0100

> commit 619c5cb6885 (New 7.0 FW: bnx2x, cnic, bnx2i, bnx2fc) added new
> sparse warnings.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
