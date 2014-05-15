From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: Register Micrel ksz884x network devices
 in PCI device tree.
Date: Thu, 15 May 2014 15:44:10 -0400 (EDT)
Message-ID: <20140515.154410.1033284719951216540.davem@davemloft.net>
References: <1400068924-13617-1-git-send-email-markus.lottmann1986@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: markus.lottmann1986@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35533 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755714AbaEOToM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 15:44:12 -0400
In-Reply-To: <1400068924-13617-1-git-send-email-markus.lottmann1986@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Lottmann <markus.lottmann1986@gmail.com>
Date: Wed, 14 May 2014 14:02:04 +0200

> This unifies the behaviour with other network device drivers and
> allows for a matching of the PCI device path in UDEV rules.
> 
> Signed-off-by: Markus Lottmann <markus.lottmann1986@gmail.com>

Applied to net-next, thanks.
