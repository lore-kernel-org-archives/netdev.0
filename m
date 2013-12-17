From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv4: new ip_no_pmtu_disc mode to always
 discard incoming frag needed msgs
Date: Tue, 17 Dec 2013 15:22:12 -0500 (EST)
Message-ID: <20131217.152212.1548747852949924535.davem@davemloft.net>
References: <20131214041345.GO23247@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3LQUWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:22:14 -0500
In-Reply-To: <20131214041345.GO23247@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 14 Dec 2013 05:13:45 +0100

> I am sorry to create a merge conflict if the patch "ipv4: improve
> documentation of ip_no_pmtu_disc" gets applied to net first. David, can you
> handle that or can I help somehow?

Don't worry, I'll sort this out.
