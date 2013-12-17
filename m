From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bonding: add some more netlink attributes
Date: Tue, 17 Dec 2013 16:10:00 -0500 (EST)
Message-ID: <20131217.161000.2196107916517833505.davem@davemloft.net>
References: <20131216003741.13453.71746.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: sfeldma@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab3LQVKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:10:04 -0500
In-Reply-To: <20131216003741.13453.71746.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@cumulusnetworks.com>
Date: Sun, 15 Dec 2013 16:41:44 -0800

> The following series implements five more bonding netlink attributes:
> 
> 	primary
> 	primary_reselect
> 	fail_over_mac
> 	xmit_hash_policy
> 	resend_igmp
> 
> Tested with modified iproute2 to verify attributes can be set at bond creation
> time or set later.  Verified sysfs interface to attributes continues to work.

Series applied, thanks Scott.
