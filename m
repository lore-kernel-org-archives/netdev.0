From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/5] stmmac: pci: remove FSF address
Date: Mon, 03 Nov 2014 15:57:08 -0500 (EST)
Message-ID: <20141103.155708.1102581898193715225.davem@davemloft.net>
References: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1415019737-32736-6-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com,
	rayagond@vayavyalabs.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbaKCU5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:57:13 -0500
In-Reply-To: <1415019737-32736-6-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Mon,  3 Nov 2014 15:02:17 +0200

> The FSF address is subject to change, thus remove it from the file.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

I cound 90t instances of this under drivers/net, therefore if this change is
appropriate I'd rather someone script this and kill it across entire
subdirectories.

Thanks.
