From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Wed, 31 Oct 2012 14:28:03 -0400 (EDT)
Message-ID: <20121031.142803.27287758379238588.davem@davemloft.net>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab2JaS2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 14:28:05 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Oct 2012 00:04:17 -0700

> This series contains updates to ixgbe, ixgbevf, igbvf, igb and
> networking core (bridge).  Most notably is the addition of support
> for local link multicast addresses in SR-IOV mode to the networking
> core.
> 
> Also note, the ixgbe patch "ixgbe: Add support for pipeline reset" and
> "ixgbe: Fix return value from macvlan filter function" is revised based
> on community feedback.

Pulled, thanks Jeff.
