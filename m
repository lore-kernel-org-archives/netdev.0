From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Fri, 28 Feb 2014 00:41:40 -0500 (EST)
Message-ID: <20140228.004140.241152706134105419.davem@davemloft.net>
References: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaB1Flo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 00:41:44 -0500
In-Reply-To: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Thu, 27 Feb 2014 20:32:39 -0800

> This series contains updates to ixgbe and ixgbevf.
> 
> Don provides an update to change a hard coded timeout interval to
> a system-wide timeout one, collects AUTOC register functions into
> one place and fixes some firmware bit handling.
> 
> Emil resolves a tx handling error introduced in a recent commit and
> adds check for CHECKSUM_PARTIAL to avoid an skb_is_gso check

Looks good, series applied, thanks Aaron.
