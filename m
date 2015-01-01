From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
 2014-12-31
Date: Wed, 31 Dec 2014 19:17:31 -0500 (EST)
Message-ID: <20141231.191731.902090516765505378.davem@davemloft.net>
References: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbbAAARd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 19:17:33 -0500
In-Reply-To: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 31 Dec 2014 16:04:12 -0800

> This series contains updates to fixes for e100, igb and i40e.
> 
> John Linville fixes a typo in e100 that has been around for some time,
> where an attempted revert actually inverted the test for eeprom_mdix_enabled.
> 
> Todd fixes up a code comment that should have been removed back in 2007.
> 
> Joe Perches fixes a possible memory leak in i40e which was reported by
> Dan Carpenter using smatch.
> 
> The following are changes since commit 2c90331cf5ed1d648a711b9483e173aaaf2c4a9b:
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
