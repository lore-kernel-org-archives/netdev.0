From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: pci: allocate memory resources dynamically
Date: Fri, 05 Dec 2014 21:04:23 -0800 (PST)
Message-ID: <20141205.210423.644541152886624620.davem@davemloft.net>
References: <1417182056-17650-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com,
	rayagond@vayavyalabs.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbaLFE7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 23:59:54 -0500
In-Reply-To: <1417182056-17650-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 28 Nov 2014 15:40:56 +0200

> Instead of using global variables we are going to use dynamically allocated
> memory. It allows to append a support of more than one ethernet adapter which
> might have different settings simultaniously.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied, thanks.
