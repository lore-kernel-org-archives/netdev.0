From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] be2net: patch set
Date: Fri, 09 May 2014 13:16:39 -0400 (EDT)
Message-ID: <20140509.131639.1863974776718809090.davem@davemloft.net>
References: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757102AbaEIRQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:16:41 -0400
In-Reply-To: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Fri, 9 May 2014 13:29:12 +0530

> This patch set contains the following modificatons:
> * three patches (1/7 to 3/7) that fix indentation style issues
> * convert the u8 vlan[] array to a bit-map to reduce memory usage
> * use MCCQ instead of MBOX in be_cmd_rss_config() as the MCCQ is already
>   created by that time
> * include rx-comp-error counter in ethtool stats
> * remove the unused promiscuous setting from be_cmd_vlan_config()
> 
> Pls apply to net-next tree. Thanks!

Series applied, thanks.
