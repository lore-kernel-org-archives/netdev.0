From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: set sysfs device_type to 'bond'
Date: Mon, 18 Feb 2013 14:49:34 -0500 (EST)
Message-ID: <20130218.144934.1015644582010518018.davem@davemloft.net>
References: <1361155127-4415-1-git-send-email-cardoe@cardoe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: cardoe@cardoe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757216Ab3BRTtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 14:49:35 -0500
In-Reply-To: <1361155127-4415-1-git-send-email-cardoe@cardoe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Goldstein <cardoe@cardoe.com>
Date: Sun, 17 Feb 2013 20:38:47 -0600

> @@ -4350,6 +4350,10 @@ static const struct net_device_ops bond_netdev_ops = {
>  	.ndo_add_slave		= bond_enslave,
>  	.ndo_del_slave		= bond_release,
>  	.ndo_fix_features	= bond_fix_features,
> +}; 
     ^^

There is trailing whitespace there, please get rid of it.

Thanks.
