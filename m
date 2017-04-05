From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH v1] NFC: Add nfc_dbg() macro
Date: Wed, 5 Apr 2017 10:16:42 +0200
Message-ID: <20170405081630.GD2136@zurbaran.ger.intel.com>
References: <20170322192251.30261-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8212 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754605AbdDEIQq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 04:16:46 -0400
Content-Disposition: inline
In-Reply-To: <20170322192251.30261-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 09:22:51PM +0200, Andy Shevchenko wrote:
> In some cases nfc_dbg() is useful. Add such macro to a header.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  include/net/nfc/nfc.h | 1 +
>  1 file changed, 1 insertion(+)
Applied as well.

Cheers,
Samuel.
