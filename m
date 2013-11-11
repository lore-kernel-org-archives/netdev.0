From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] igb: Update link modes display in ethtool
Date: Mon, 11 Nov 2013 00:46:44 -0500 (EST)
Message-ID: <20131111.004644.2260568400720991750.davem@davemloft.net>
References: <1384001534-18709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3KKFqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 00:46:47 -0500
In-Reply-To: <1384001534-18709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  9 Nov 2013 04:52:14 -0800

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch fixes multiple problems in the link modes display in ethtool.
> Newer parts have more complicated methods to determine actual link
> capabilities.  Older parts cannot communicate with their SFP modules.
> Finally, all the available defines are not displayed by ethtool.  This
> updates the link modes to be as accurate as possible depending on what data
> is available to the driver at any given time.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
