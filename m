From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v6 net-next 0/2] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 18:38:49 -0800 (PST)
Message-ID: <20140117.183849.161810150934219942.davem@davemloft.net>
References: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	ethan.kernel@gmail.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbaARCiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:38:50 -0500
In-Reply-To: <1389930065-3330-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Thu, 16 Jan 2014 19:41:03 -0800

> This series contains updates to ixgbe Ethan Zhao.  The first one replaces
> the magic number "63" with a macro, IXGBE_MAX_VFS_DRV_LIMIT, the second 
> moves the call to set driver_max_VFS to before SRIOV is enabled.
> 
> The code of these patches match the v3 (1/2) and v2 (2/2) versions sent
> to the e1000-devel and netdev mailing lists.  The intermediate versions
> (v4, v5) are from sorting out style issues, mostly tabs to spaces and
> split lines probably introduced via mailer.

Series applied, thanks.
