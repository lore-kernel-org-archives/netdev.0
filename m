From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] PHY configuration for compatible issue
Date: Sun, 27 Nov 2011 19:22:15 -0500 (EST)
Message-ID: <20111127.192215.967657487181840962.davem@davemloft.net>
References: <1321906842-1476-1-git-send-email-AriesLee@jmicron.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariesleeILan@gmail.com, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: AriesLee@jmicron.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab1K1AXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 19:23:38 -0500
In-Reply-To: <1321906842-1476-1-git-send-email-AriesLee@jmicron.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: AriesLee <AriesLee@jmicron.com>
Date: Tue, 22 Nov 2011 04:20:42 +0800

> To perform PHY calibration and set a different EA value by chip ID,
> Whenever the NIC chip power on, ie booting or resuming, we need to
> force HW to calibrate PHY parameter again, and also set a proper EA
> value which gather from experiment.
> 
> Those procedures help to reduce compatible issues(NIC is unable to link
> up in some special case) in giga speed.
> 
> Signed-off-by: AriesLee <AriesLee@jmicron.com>

Applied, thanks.
