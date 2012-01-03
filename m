From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/11] netdev: FCoE: Add new ndo_get_fcoe_hbainfo()
 call
Date: Tue, 03 Jan 2012 15:07:42 -0500 (EST)
Message-ID: <20120103.150742.289215241240567940.davem@davemloft.net>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Neerav.Parikh@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731Ab2ACUHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:07:46 -0500
In-Reply-To: <1325618356-2655-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Jan 2012 11:19:10 -0800

> +	int			(*ndo_fcoe_get_hbainfo)(struct net_device *dev,
> +					struct netdev_fcoe_hbainfo *hbainfo);

Please line up the second line's argument correctly, it should be:

> +	int			(*ndo_fcoe_get_hbainfo)(struct net_device *dev,
> +							struct netdev_fcoe_hbainfo *hbainfo);

Thanks.
