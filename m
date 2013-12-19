From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bonding: add even more netlink attributes
Date: Thu, 19 Dec 2013 18:33:15 -0500 (EST)
Message-ID: <20131219.183315.2184861342450197731.davem@davemloft.net>
References: <20131218052755.13529.61835.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756449Ab3LSXdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:33:17 -0500
In-Reply-To: <20131218052755.13529.61835.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Tue, 17 Dec 2013 21:30:02 -0800

> The following series implements five more bonding netlink attributes:
> 
> 	num_grat_arp|num_unsol_na
> 	all_slaves_active
> 	min_links
> 	lp_interval
> 	packets_per_slave
> 
> Tested with modified iproute2 to verify attributes can be set at bond creation
> time or set later.  Verified sysfs interface to attributes continues to work.
> 
> I have one more set after this one for all of the 802.3ad attributes.  Whew.

You have much more stamina than I do, that's for sure :-)

Series applied, thanks!
