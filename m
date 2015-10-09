From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 1/1] i40e: re-use %*ph specifier to hexdump a data
Date: Fri, 9 Oct 2015 13:28:57 -0700
Message-ID: <20151009132857.00002b95@unknown>
References: <1443777496-43299-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33061 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbbJIU26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 16:28:58 -0400
In-Reply-To: <1443777496-43299-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Oct 2015 12:18:16 +0300
Andy Shevchenko <andriy.shevchenko@linux.intel.com> wrote:

> Instead of using a custom approach change the code to use %*ph format
> specifier.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Nice catch, thanks!

Acked-by: jesse Brandeburg <jesse.brandeburg@intel.com>
