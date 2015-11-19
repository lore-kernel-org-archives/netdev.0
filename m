From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 11:50:09 -0500 (EST)
Message-ID: <20151119.115009.1527824925656415982.davem@davemloft.net>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151119.113336.1788979303067913870.davem@davemloft.net>
	<1447951414.22599.226.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zenczykowski@gmail.com, lorenzo@google.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	dtor@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758476AbbKSQuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 11:50:12 -0500
In-Reply-To: <1447951414.22599.226.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Nov 2015 08:43:34 -0800

> You already rejected some of my patches, obviously.

Of course, and I applied quickly all the really nice ones,
many of them... :-)
