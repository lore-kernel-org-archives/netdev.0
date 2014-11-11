From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: bcmgenet: power management related fixes
Date: Tue, 11 Nov 2014 18:24:30 -0500 (EST)
Message-ID: <20141111.182430.356396210708183668.davem@davemloft.net>
References: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbaKKXYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:24:33 -0500
In-Reply-To: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 10 Nov 2014 18:06:19 -0800

> These two patches fixes issues seen while testing power management on
> platforms using the GENET driver.
> 
> First patch fixes an issue with the PHY state machine queuing work after
> resume since we are not properly detached from it.
> 
> Second patch fixes an issue with GENET interfaces that were not properly
> restored to a working state after a S3 suspend/resume cycle.

Series applied, thanks.
