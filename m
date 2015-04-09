From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: rename work handler
Date: Thu, 09 Apr 2015 14:38:14 -0400 (EDT)
Message-ID: <20150409.143814.58972069012673104.davem@davemloft.net>
References: <1428566944-21376-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923AbbDISiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:38:15 -0400
In-Reply-To: <1428566944-21376-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Thu,  9 Apr 2015 10:09:04 +0200

> "kevent" is an extremely generic name that causes trouble
> if debugging for work queues is used. So change it to
> something clear.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Indeed, applied, thanks Oliver.
