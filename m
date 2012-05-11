From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: irda-usb.c URL to sigmatel stir 4210/4220/4116
 fw from archive.org
Date: Thu, 10 May 2012 23:23:15 -0400 (EDT)
Message-ID: <20120510.232315.682267960099945551.davem@davemloft.net>
References: <1336167477-28835-1-git-send-email-xose.vazquez@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xose.vazquez@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758876Ab2EKDYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:24:25 -0400
In-Reply-To: <1336167477-28835-1-git-send-email-xose.vazquez@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Date: Fri,  4 May 2012 23:37:57 +0200

> @@ -1081,6 +1081,7 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
>          /*
>           * Known firmware patch file names for STIR421x dongles
>           * are "42101001.sb" or "42101002.sb"
> +         * http://web.archive.org/web/http://www.sigmatel.com/documents/stir4210_4220_4116_patch_files.tar.gz

This really doesn't scale in the long term.

Someone needs to host this firmware at a location which serves the
needs of the people who have an interest in using this driver.
