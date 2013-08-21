From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] tun: Add ability to create tun device with given
 index
Date: Tue, 20 Aug 2013 23:26:07 -0700 (PDT)
Message-ID: <20130820.232607.1288436301791887019.davem@davemloft.net>
References: <52123515.3060507@parallels.com>
	<5212352C.4050904@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab3HUG0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 02:26:08 -0400
In-Reply-To: <5212352C.4050904@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 19 Aug 2013 19:09:32 +0400

> +		unsigned ifindex;

Please use explicitly "unsigned int"

> +	unsigned ifindex;

Likewise.
