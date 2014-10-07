From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: optimizing the receive path?
Date: Tue, 07 Oct 2014 14:49:25 -0400 (EDT)
Message-ID: <20141007.144925.1436185932073418204.davem@davemloft.net>
References: <20141004.204203.2211720828886085354.davem@davemloft.net>
	<5432936D.7010906@gmail.com>
	<5434246E.1000403@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbaJGSt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:49:27 -0400
In-Reply-To: <5434246E.1000403@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Tue, 07 Oct 2014 13:35:42 -0400

> So if there are no objections, I will post as a formal patch.

No objections from me, thanks for all the info.
