From: David Miller <davem@davemloft.net>
Subject: Re: [NET_NEXT RFC PATCH 2/3] ixgbe: added netdev_ops file to
 debugfs
Date: Thu, 10 May 2012 17:21:16 -0400 (EDT)
Message-ID: <20120510.172116.581086534135626936.davem@davemloft.net>
References: <F1C1314B3E1AB7499F9BF2A5F0F033EC14A8F3@FMSMSX104.amr.corp.intel.com>
	<20120510.163207.1812696843582837101.davem@davemloft.net>
	<F1C1314B3E1AB7499F9BF2A5F0F033EC14AA1B@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: catherine.sullivan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757492Ab2EJVVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 17:21:21 -0400
In-Reply-To: <F1C1314B3E1AB7499F9BF2A5F0F033EC14AA1B@FMSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sullivan, Catherine" <catherine.sullivan@intel.com>
Date: Thu, 10 May 2012 21:14:49 +0000

> I was aware of this, however this does not allow a call to the
> ndo_tx_timeout function which is what my patch does. Is there a way
> to do this with sysfs? I could not find this functionality.

Please stop top-posting.
