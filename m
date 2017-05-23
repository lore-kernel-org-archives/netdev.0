From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cdc-ether: divorce initialisation with a filter
 reset and a generic method
Date: Tue, 23 May 2017 11:01:56 -0400 (EDT)
Message-ID: <20170523.110156.1205611614564101503.davem@davemloft.net>
References: <20170522125030.21266-1-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn@mork.no
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759629AbdEWPCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:02:06 -0400
In-Reply-To: <20170522125030.21266-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Mon, 22 May 2017 14:50:30 +0200

> Some devices need their multicast filter reset but others are crashed by that.
> So the methods need to be separated.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> Reported-by: "Ridgway, Keith" <kridgway@harris.com>

Applied and queued up for -stable, thanks Oliver.
