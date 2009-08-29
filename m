From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST net-next-2.6 0/4] bonding: Four patches
Date: Fri, 28 Aug 2009 23:02:02 -0700 (PDT)
Message-ID: <20090828.230202.139753601.davem@davemloft.net>
References: <1251497115-16234-1-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751634AbZH2GBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:01:49 -0400
In-Reply-To: <1251497115-16234-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 28 Aug 2009 15:05:11 -0700

> 	Four patches for bonding:
> 
> 	Patch 1 adds the propogation of vlan_features from the slaves
> to the master device.
> 
> 	Patch 2 replaces a cumbersome manual MAC address comparison with
> compare_ether_addr.
> 
> 	Patch 3 removes a useless test against INT_MAX
> 
> 	Patch 4 modifies bond_check_dev_link to handle devices that leave
> carrier up even when adminstratively down.
> 
> 	Due to lab machine adventures on my end, I was only able to compile
> test patches 2 - 4.
> 
> 	Please apply for net-next-2.6.

All looks good, applied, thanks!
