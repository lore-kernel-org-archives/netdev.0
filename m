From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] bonding: Fix some issues for
 fail_over_mac
Date: Fri, 24 Jan 2014 18:04:27 -0800 (PST)
Message-ID: <20140124.180427.1942816445484474722.davem@davemloft.net>
References: <52E1EBB0.6040505@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org,
	andy@greyhouse.net
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbaAYCEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 21:04:32 -0500
In-Reply-To: <52E1EBB0.6040505@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 24 Jan 2014 12:27:28 +0800

> So set the fail_over_mac to none if the mode is not active-backup and
> slight optimization for bond_set_mac_address().

This is no longer how your series fixes the problem, please fix this
text and resubmit.
