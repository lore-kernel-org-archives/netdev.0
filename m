From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12] bna: Update the Driver to v3.2.23.0
Date: Wed, 18 Dec 2013 00:31:59 -0500 (EST)
Message-ID: <20131218.003159.1191579811911283092.davem@davemloft.net>
References: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab3LRFcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:32:05 -0500
In-Reply-To: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 17 Dec 2013 17:07:30 -0800

> This patch set consists of feature additions like s/w timestamping support,
> multi-buffer RX, firmware patch simplification, enhancements for RX filters,
> RX processing changes, bug fixes and updates the firmware version to v3.2.3.0.
> The patch set addressed the review commnets recieved.
> 
> This patch set updates the BNA driver to v3.2.23.0 and was tested against
> net-next 3.12.0-rc6 kernel.

Series applied, thank you.

Nice comments for the memory barriers.
