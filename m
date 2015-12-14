From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 2/2] net:hns: print MAC with %pM
Date: Sun, 13 Dec 2015 23:37:34 -0500 (EST)
Message-ID: <20151213.233734.1535353072666775593.davem@davemloft.net>
References: <1449760990-111046-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<1449760990-111046-2-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, huangdaode@hisilicon.com,
	linux@rasmusvillemoes.dk
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbLNEhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 23:37:36 -0500
In-Reply-To: <1449760990-111046-2-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 10 Dec 2015 17:23:10 +0200

> printf() has a dedicated specifier to print MAC addresses. Use it instead of
> pushing each byte via stack.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Applied.
