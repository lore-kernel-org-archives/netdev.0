From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: fix a typo in
 __udp4_lib_mcast_demux_lookup
Date: Wed, 09 Oct 2013 02:01:19 -0400 (EDT)
Message-ID: <20131009.020119.1302933717342377227.davem@davemloft.net>
References: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
	<20131008.165147.1204109363656237950.davem@davemloft.net>
	<1381294049.4971.3.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.bohrer@gmail.com, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, sbohrer@rgmadvisors.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab3JIGBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 02:01:23 -0400
In-Reply-To: <1381294049.4971.3.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Oct 2013 21:47:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> At this point sk might contain garbage.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
