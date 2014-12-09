From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: platform: adjust messages and move to dev level
Date: Tue, 09 Dec 2014 18:28:37 -0500 (EST)
Message-ID: <20141209.182837.2218983730769727387.davem@davemloft.net>
References: <1418119153-13355-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536AbaLIX2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:28:39 -0500
In-Reply-To: <1418119153-13355-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue,  9 Dec 2014 11:59:13 +0200

> This patch amendes error and warning messages across the platform driver. It
> includes the following changes:
>  - remove unneccessary message when no memory is available
>  - change info level to warn in the validation functions
>  - append \n to the end of messages
>  - change pr_* macros to dev_*
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

This does not apply to the net-next tree, please respin.
