From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_subset: deal with a device that needs reset for
 timeout
Date: Sat, 02 Aug 2014 15:44:32 -0700 (PDT)
Message-ID: <20140802.154432.279508234748584239.davem@davemloft.net>
References: <1406894511-26808-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbaHBWod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 18:44:33 -0400
In-Reply-To: <1406894511-26808-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Fri,  1 Aug 2014 14:01:51 +0200

> This device needs to be reset to recover from a timeout.
> Unfortunately this can be handled only at the level of
> the subdrivers.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied, thanks Oliver.
