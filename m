From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] net: dsa: add private context accessor
Date: Wed, 30 Apr 2014 13:31:43 -0400 (EDT)
Message-ID: <20140430.133143.456398062536728773.davem@davemloft.net>
References: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbaD3Rbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:31:48 -0400
In-Reply-To: <1398708868-15084-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 28 Apr 2014 11:14:26 -0700

> This patchset adds a private context accessors instead of doing the
> (void *)(ds + 1) trick in DSA drivers that require the use of a private
> context.

Series applied, thanks.
