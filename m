From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Tue, 11 Nov 2014 13:34:24 -0500 (EST)
Message-ID: <20141111.133424.1799983435442639164.davem@davemloft.net>
References: <1415591939-1535-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbaKKSe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:34:27 -0500
In-Reply-To: <1415591939-1535-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun,  9 Nov 2014 19:58:59 -0800

> Following batch of patches brings feature parity between upstream
> ovs and out of tree ovs module.
> 
> Two features are added, first adds support to export egress
> tunnel information for a packet. This is used to improve
> visibility in network traffic. Second feature allows userspace
> vswitchd process to probe ovs module features. Other patches
> are optimization and code cleanup.

Pulled, thanks Pravin.
