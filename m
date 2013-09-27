From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] be2net: Bug fixes
Date: Fri, 27 Sep 2013 17:12:22 -0400 (EDT)
Message-ID: <20130927.171222.1728408149567139486.davem@davemloft.net>
References: <20130927201654.GA4494@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab3I0VMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:12:24 -0400
In-Reply-To: <20130927201654.GA4494@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Fri, 27 Sep 2013 15:16:54 -0500

> Series of 7 patches against net tree.
> Please apply.
 ...
> [1/7] be2net: Fix to prevent Tx stall on SH-R when packet size < 32
> [2/7] be2net: Fix the size of be_nic_res_desc structure
> [3/7] be2net: Fix VLAN promiscuous mode programming
> [4/7] be2net: Fix number of VLANs supported in UMC mode for BE3-R.
> [5/7] be2net: Fix to allow VLAN configuration on VF interfaces.
> [6/7] be2net: Fix to configure VLAN priority for a VF interface.
> [7/7] be2net: Fix to display the VLAN priority for a VF

Series applied, thanks.
