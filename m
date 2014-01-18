From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/3] Intel Wired LAN Driver Updates
Date: Fri, 17 Jan 2014 18:58:03 -0800 (PST)
Message-ID: <20140117.185803.2035894522113827323.davem@davemloft.net>
References: <1389950498-8820-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbaARC6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 21:58:04 -0500
In-Reply-To: <1389950498-8820-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Fri, 17 Jan 2014 01:21:35 -0800

> This series contains an updates to ixgbe and ixgbevf.
> 
> Jacob add braces around some ixgbe_qv_lock_* calls lto better adhere 
> to Kernel style guidelines.  Don bumps the versions on ixgbe and
> ixgbevf to match internal driver functionality better.

Series applied, thanks.
