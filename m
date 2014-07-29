From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_subset: deal with a device that needs reset for
 timeout
Date: Tue, 29 Jul 2014 12:22:35 -0700 (PDT)
Message-ID: <20140729.122235.1073781660677577471.davem@davemloft.net>
References: <1406535154-11540-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaG2TWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 15:22:36 -0400
In-Reply-To: <1406535154-11540-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Mon, 28 Jul 2014 10:12:34 +0200

> This device needs to be reset to recover from a timeout.
> Unfortunately this can be handled only at the level of
> the subdrivers.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied.
