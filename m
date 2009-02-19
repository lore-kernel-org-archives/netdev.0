From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: remove LRO Kconfig option
Date: Wed, 18 Feb 2009 17:56:31 -0800 (PST)
Message-ID: <20090218.175631.113423582.davem@davemloft.net>
References: <20090218092323.21256.81827.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753785AbZBSB4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:56:47 -0500
In-Reply-To: <20090218092323.21256.81827.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 18 Feb 2009 01:23:27 -0800

> To match ixgbe GRO functionality, we remove the LRO (which is now GRO) Kconfig option which enables GRO by default.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
