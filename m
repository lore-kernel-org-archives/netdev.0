From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 11:38:59 -0400 (EDT)
Message-ID: <20170523.113859.1803057381093280239.davem@davemloft.net>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
        <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
        <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, jiri@resnulli.us, netdev@vger.kernel.org,
        idosch@mellanox.com, mlxsw@mellanox.com, bhutchings@solarflare.com
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761492AbdEWPjC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:39:02 -0400
In-Reply-To: <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Tue, 23 May 2017 18:14:15 +0300

> Sorry, I am not sure I understand. You think that drivers should not implement
> ethtool's flash_device callback anymore? do you have an alternative for firmware
> flash?

As stated, export an MTD device.
