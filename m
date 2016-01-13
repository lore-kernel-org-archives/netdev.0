From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Add eth_platform_get_mac_address() helper.
Date: Tue, 12 Jan 2016 21:40:23 -0500 (EST)
Message-ID: <20160112.214023.1997265058149196384.davem@davemloft.net>
References: <20160106.163309.111867454969344145.davem@davemloft.net>
	<20160113004916.GA28880@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbcAMCka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 21:40:30 -0500
In-Reply-To: <20160113004916.GA28880@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 12 Jan 2016 19:49:16 -0500

> I finally have all the ducks lined up for ixgbe/i40e around this. 
> Should I go ahead and send this off (I think it first gets staged 
> through Jeff's repo?) or is it better to wait for net-next to be 
> open again?

If you want to send it to Jeff and the Intel folks for them to
queue it up there, that's fine.
