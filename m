From: David Miller <davem@davemloft.net>
Subject: Re: [net 3/3] igb: Fixes needed for surprise removal support
Date: Sun, 23 Nov 2014 14:27:15 -0500 (EST)
Message-ID: <20141123.142715.1046322185203400142.davem@davemloft.net>
References: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1416642774-17077-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	yanirx.lubetkin@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbaKWT1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:27:17 -0500
In-Reply-To: <1416642774-17077-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2014 23:52:54 -0800

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch adds some checks in order to prevent panic's on surprise
> removal of devices during S0, S3, S4.  Without this patch, Thunderbolt
> type device removal will panic the system.
> 
> Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
