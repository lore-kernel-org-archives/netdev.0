From: David Miller <davem@davemloft.net>
Subject: Re: [patch] USB: cdc_ether: remove unneeded check
Date: Fri, 31 Dec 2010 11:11:47 -0800 (PST)
Message-ID: <20101231.111147.260086991.davem@davemloft.net>
References: <20101225222341.GS1936@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@suse.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622Ab0LaTLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 14:11:17 -0500
In-Reply-To: <20101225222341.GS1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 26 Dec 2010 01:23:42 +0300

> We already verified that "dev->udev->actconfig->extralen" was non-zero
> so "len" is non-zero here as well.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
