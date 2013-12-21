From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix missing include file
Date: Sat, 21 Dec 2013 00:00:55 -0500 (EST)
Message-ID: <20131221.000055.1377147691178558975.davem@davemloft.net>
References: <20131221025110.9758.12509.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3LUFBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 00:01:33 -0500
In-Reply-To: <20131221025110.9758.12509.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Fri, 20 Dec 2013 18:51:10 -0800

> Compile error reported by Jim Davis on netdev.
> 
> ip6_sk_accept_pmtu() needs net/ip6_route.h
> 
> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Applied, thanks.
