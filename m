From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Tue, 05 Jul 2011 23:44:24 -0700 (PDT)
Message-ID: <20110705.234424.2099388019260070145.davem@davemloft.net>
References: <CA+mtBx8www2eNp38EDuagYMQGSYivG7SN4ffozz4QtZPZqubSQ@mail.gmail.com>
	<20110705.201950.199250194399828543.davem@davemloft.net>
	<1309925266.2545.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, victor@inliniac.net, netdev@vger.kernel.org,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab1GFGod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 02:44:33 -0400
In-Reply-To: <1309925266.2545.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jul 2011 06:07:46 +0200

> I suspect this can be solved adding a third policy : hash by CPU only

Agreed, I'll implement this policy.
