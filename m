From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] broadcom: add include guards to include/linux/brcmphy.h
Date: Wed, 15 May 2013 14:54:58 -0700 (PDT)
Message-ID: <20130515.145458.700897173953931240.davem@davemloft.net>
References: <1368640825-22382-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cernekee@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab3EOVy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:54:59 -0400
In-Reply-To: <1368640825-22382-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Wed, 15 May 2013 18:00:25 +0000

> include/linux/brcmphy.h is currently not protected against double
> inclusion, add ifdefs guard to fix that.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
