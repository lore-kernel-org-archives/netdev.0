From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/3] Control VF link state
Date: Thu, 13 Jun 2013 17:51:28 -0700 (PDT)
Message-ID: <20130613.175128.633380066489526678.davem@davemloft.net>
References: <1371118752-2314-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab3FNAv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 20:51:29 -0400
In-Reply-To: <1371118752-2314-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 13 Jun 2013 13:19:09 +0300

> These patches add API and implementation that lets the admin to configure the link 
> state of the VF / SRIOV  eSwitch vPORT. Basically, it has three states
> 
> Auto - VF link state reflects the PF link state (default)
> 
> Up - VF link state is up, traffic from VF to VF works even if
> the actual PF link is down
> 
> Down - VF link state is down, no traffic from/to this VF, can be of
> use while configuring the VF

Applied with trailing whitespace errors fixed in patch #1.

Thanks.
