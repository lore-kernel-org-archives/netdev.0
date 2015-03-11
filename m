From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Wed, 11 Mar 2015 13:14:57 -0400 (EDT)
Message-ID: <20150311.131457.1314699780103858026.davem@davemloft.net>
References: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	hadarh@mellanox.com, yevgenyp@mellanox.com, ogerlitz@mellanox.com,
	talal@mellanox.com, shannon.nelson@intel.com, dledford@redhat.com,
	greearb@candelatech.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbCKRPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:15:04 -0400
In-Reply-To: <1426064933-29072-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 11 Mar 2015 11:08:50 +0200

> Also, customers are paying for a very sophisticated piece of
> hardware, and we would like to enable power user to tweak it in some
> situtations. Of course the default mode should be used in 99% of the
> use cases.

How much money someone pays for your hardware has nothing to do with
the standards by which we design userspace interfaces to configure
these devices.

These textual interfaces are arbitrary, and you are choosing it only
because you cannot come up with a more reasonable scheme,

I'm not applying these changes.
