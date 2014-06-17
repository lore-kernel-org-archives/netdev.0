From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] isdn: hisax: Merge Kconfig ifs
Date: Mon, 16 Jun 2014 21:31:49 -0700 (PDT)
Message-ID: <20140616.213149.621072289955642281.davem@davemloft.net>
References: <1402906177.13305.1.camel@chaos.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaFQEbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:31:51 -0400
In-Reply-To: <1402906177.13305.1.camel@chaos.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 16 Jun 2014 10:09:37 +0200

> The first half of the HiSax config options is presented if
> ISDN_DRV_HISAX!=n, while the second half of the options is presented
> if ISDN_DRV_HISAX. That's the same, so merge both conditionals.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied.
