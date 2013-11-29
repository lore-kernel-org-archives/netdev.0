From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: ip6_pkt_prohibit(_out) should not depend on
 CONFIG_IPV6_MULTIPLE_TABLES
Date: Fri, 29 Nov 2013 16:39:30 -0500 (EST)
Message-ID: <20131129.163930.203685593163996122.davem@davemloft.net>
References: <1385629923-22920-1-git-send-email-kamala@aristanetwors.com>
	<20131128190411.GD24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kamala@aristanetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712Ab3K2Vjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:39:31 -0500
In-Reply-To: <20131128190411.GD24171@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 28 Nov 2013 20:04:11 +0100

> Since patch "IPv6: Fixed support for blackhole and prohibit routes" we
> need ip6_pkt_prohibit(_out) available without CONFIG_IPV6_MULTIPLE_TABLES
> defined.
> 
> Cc: Kamala R <kamala@aristanetworks.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Please reference the SHA1 ID of the change as well as it's commit
header text, thank you.
