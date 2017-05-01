From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/3] bnx2x: Replace custom scnprintf()
Date: Sun, 30 Apr 2017 22:29:00 -0400 (EDT)
Message-ID: <20170430.222900.1542294063210792919.davem@davemloft.net>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        andy.shevchenko@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165169AbdEAC3C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:29:02 -0400
In-Reply-To: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 27 Apr 2017 16:36:59 +0300

> From: Andy Shevchenko <andy.shevchenko@gmail.com>
> 
> Use scnprintf() when printing version instead of custom open coded variants.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>

Applied.
