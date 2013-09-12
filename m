From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] igb: Add additional get_phy_id call for i354 devices
Date: Thu, 12 Sep 2013 16:25:21 -0400 (EDT)
Message-ID: <20130912.162521.626940899801955559.davem@davemloft.net>
References: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab3ILUZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 16:25:24 -0400
In-Reply-To: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 10 Sep 2013 11:57:16 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch fixes a problem where some ports can fail to initialize on a
> cold boot. This patch adds an additional call to read the PHY id for i354
> devices in order workaround the hardware problem.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
