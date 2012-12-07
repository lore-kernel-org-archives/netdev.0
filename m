From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v2] sctp: RCU protection when accessing assoc
 members for procfs
Date: Fri, 07 Dec 2012 14:15:58 -0500 (EST)
Message-ID: <20121207.141558.432893641652497152.davem@davemloft.net>
References: <cover.1354821623.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com, nhorman@tuxdriver.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab2LGTQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:16:00 -0500
In-Reply-To: <cover.1354821623.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu,  6 Dec 2012 20:25:03 +0100

> @Dave: This is a respin of the following patches:
>   [PATCH] sctp: proc: protect bind_addr->address_list accesses with rcu_read_lock()
>   [PATCH] sctp: Add RCU protection to assoc->transport_addr_list
> 
> Thomas Graf (2):
>   sctp: proc: protect bind_addr->address_list accesses with
>     rcu_read_lock()
>   sctp: Add RCU protection to assoc->transport_addr_list

Series applied, thanks.
