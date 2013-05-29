From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/usb/kalmia: use %*phC to dump small buffers
Date: Wed, 29 May 2013 00:35:38 -0700 (PDT)
Message-ID: <20130529.003538.781072711999958516.davem@davemloft.net>
References: <1369812150-27599-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935099Ab3E2Hfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 03:35:39 -0400
In-Reply-To: <1369812150-27599-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Wed, 29 May 2013 10:22:30 +0300

> Instead of dereferencing pointer and put values on stack we could use nice
> %*phC specifier.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied, thanks.
