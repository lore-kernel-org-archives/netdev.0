From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: phy: phy_interface_is_rgmii helper
Date: Wed, 27 May 2015 00:27:56 -0400 (EDT)
Message-ID: <20150527.002756.1418735064606746085.davem@davemloft.net>
References: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmurphy@ti.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbE0E15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:27:57 -0400
In-Reply-To: <1432667999-11563-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 26 May 2015 12:19:57 -0700

> As you suggested, here is the helper function to avoid missing some RGMII
> interface checks. Had to wait for net to be merged in net-next to avoid
> submitting the same patch/commit.
> 
> Dan, you might want to rebase your dp83867 submission to use that helper
> when you this patchset gets merged into net-next, thanks!

Applied, thanks for following up on this.
