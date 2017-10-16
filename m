From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pch_gbe: Switch to new PCI IRQ allocation API
Date: Mon, 16 Oct 2017 21:13:01 +0100 (WEST)
Message-ID: <20171016.211301.1701189621414254055.davem@davemloft.net>
References: <20171014140440.21439-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753255AbdJPUND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:13:03 -0400
In-Reply-To: <20171014140440.21439-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Sat, 14 Oct 2017 17:04:40 +0300

> This removes custom flag handling.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied to net-next, thanks.
