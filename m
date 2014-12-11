From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Driver: Vmxnet3: Make Rx ring 2 size configurable
Date: Thu, 11 Dec 2014 12:05:14 -0500 (EST)
Message-ID: <20141211.120514.1224165557764220263.davem@davemloft.net>
References: <1418276262-4728-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bollar@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311AbaLKRFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 12:05:17 -0500
In-Reply-To: <1418276262-4728-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Wed, 10 Dec 2014 21:37:42 -0800

> Rx ring 2 size can be configured by adjusting rx-jumbo parameter
> of ethtool -G.
> 
> Signed-off-by: Ramya Bolla <bollar@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

This is a new feature patch, and the net-next tree is closed, therefore
it is not appropriate to submit a change like this at this time.

Please resubmit when the net-next tree opens back up, some time after
the merge window is over.
