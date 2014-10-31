From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] stmmac: pci: set default of the filter bins
Date: Fri, 31 Oct 2014 16:10:50 -0400 (EDT)
Message-ID: <20141031.161050.1067629196847570490.davem@davemloft.net>
References: <1414772883-29503-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com,
	stable@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003AbaJaULA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 16:11:00 -0400
In-Reply-To: <1414772883-29503-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Fri, 31 Oct 2014 18:28:03 +0200

> The commit 3b57de958e2a brought the support for a different amount of the
> filter bins, but didn't update the PCI driver accordingly. This patch appends
> the default values when the device is enumerated via PCI bus.
> 
> Fixes: 3b57de958e2a (net: stmmac: Support devicetree configs for mcast and ucast filter entries)
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: stable@vger.kernel.org

Applied, thanks.
