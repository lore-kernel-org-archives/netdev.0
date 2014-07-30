From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-subset: make compile with all config options
Date: Wed, 30 Jul 2014 13:20:00 -0700 (PDT)
Message-ID: <20140730.132000.301302545563342971.davem@davemloft.net>
References: <1406710486-29138-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbaG3UUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 16:20:04 -0400
In-Reply-To: <1406710486-29138-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Wed, 30 Jul 2014 10:54:46 +0200

> My earlier patch introduced helper methods errornously
> subject to conditional compilation. This patch makes them
> available under all config options.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Oliver, since I had Linus revert your patch (in order to expedite the
3.16-final release), you'll need to send me your original patch with
these fixes here included.

Thanks.
