From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] stmmac: pci: various cleanups and fixes
Date: Thu, 06 Nov 2014 14:39:25 -0500 (EST)
Message-ID: <20141106.143925.142675354079151393.davem@davemloft.net>
References: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaKFTj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:39:29 -0500
In-Reply-To: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed,  5 Nov 2014 12:27:25 +0200

> There are few cleanups and fixes regarding to stmmac PCI driver.
> This has been tested on Intel Galileo board with recent net-next tree.
> 
> Since v2:
> - drop patch 5/5 since it will be part of a big change across entire subsystem
> 
> Since v1:
> - remove already applied patch
> - append patch 1/5
> - rework patch 3/5 to be functional compatible with original code

These look fine, series applied to net-next, thanks.
