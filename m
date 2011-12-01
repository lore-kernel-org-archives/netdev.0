From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] Respin of dynamic neigh patches.
Date: Wed, 30 Nov 2011 22:41:26 -0500 (EST)
Message-ID: <20111130.224126.861892931279091501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab1LADl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:28 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fRs1027291
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:27 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just is just a respin of the neighbour layer patches I posted some
time ago which allows us to get rid of the ATM specific code in
net/ipv4/route.c

Committed to net-next
