From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] cdc-ether: switch to common CDC parser
Date: Tue, 15 Sep 2015 12:44:09 -0700 (PDT)
Message-ID: <20150915.124409.1442031801027805891.davem@davemloft.net>
References: <1441634742-19856-1-git-send-email-oneukum@suse.com>
	<1441634742-19856-3-git-send-email-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org, bjorn@mork.no
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbbIOToJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 15:44:09 -0400
In-Reply-To: <1441634742-19856-3-git-send-email-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Mon,  7 Sep 2015 16:05:40 +0200

> This patch uses the common parser to parse extra CDC
> headers in order to reduce code duplication.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.com>

Applied.
