From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/6] net: add team multiqueue support and do
 comple of thing on the way
Date: Fri, 20 Jul 2012 11:08:20 -0700 (PDT)
Message-ID: <20120720.110820.889150615765731834.davem@davemloft.net>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2GTSIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:08:21 -0400
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 20 Jul 2012 14:28:45 +0200

> This patchset represents the way I walked when I was adding multiqueue support for
> team driver.
> 
> Jiri Pirko (6):
>   net: honour netif_set_real_num_tx_queues() retval
>   rtnl: allow to specify different num for rx and tx queue count
>   rtnl: allow to specify number of rx and tx queues on device creation
>   net: rename bond_queue_mapping to slave_dev_queue_mapping
>   bond_sysfs: use ream_num_tx_queues rather than params.tx_queue
>   team: add multiqueue support

All applied, thanks Jiri.
