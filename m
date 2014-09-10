From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] irda: vlsi_ir: use %*ph specifier
Date: Tue, 09 Sep 2014 20:11:38 -0700 (PDT)
Message-ID: <20140909.201138.1319870861702360791.davem@davemloft.net>
References: <1410252509-26242-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbaIJDLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 23:11:39 -0400
In-Reply-To: <1410252509-26242-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue,  9 Sep 2014 11:48:29 +0300

> Instead of looping in the code let's use kernel extension to dump small
> buffers.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
