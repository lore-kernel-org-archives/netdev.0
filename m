From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9] tilegx network driver: initial support
Date: Wed, 06 Jun 2012 09:41:35 -0700 (PDT)
Message-ID: <20120606.094135.768228524411466462.davem@davemloft.net>
References: <20120524.003148.700603156196416506.davem@davemloft.net>
	<201205251853.q4PIrE7T000723@lab-41.internal.tilera.com>
	<201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 4 Jun 2012 16:12:03 -0400

> This change adds support for the tilegx network driver based on the
> GXIO IORPC support in the tilegx software stack, using the on-chip
> mPIPE packet processing engine.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This change fixes some bugs that were discovered during additional
> testing of the TSO refactoring.  In addition, I added a comment
> explaining why we provide TSO support as essentially driver-side GSO.
> 
> The previous v8 version of the patch (from 10 days ago) received no
> feedback; if anyone would care to provide feedback on this version of
> the driver, it would be much appreciated.  Thanks!

Someone other than me please review this driver.
