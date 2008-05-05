From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Sun, 04 May 2008 22:20:50 -0700 (PDT)
Message-ID: <20080504.222050.195185590.davem@davemloft.net>
References: <a8e1da0805041958k30c03e20r6dd88f4135d6e5fe@mail.gmail.com>
	<1209955974.13011.10.camel@localhost>
	<a8e1da0805042218l6fbacfd9sa139b00c3077895b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hidave.darkstar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40457
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbYEEFUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 01:20:50 -0400
In-Reply-To: <a8e1da0805042218l6fbacfd9sa139b00c3077895b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dave Young" <hidave.darkstar@gmail.com>
Date: Mon, 5 May 2008 13:18:30 +0800

> After searching the code, I guess DCCP-Sync ratelimit can use this feature.
> David, am I right?

I'm not familiar with the DCCP-Sync code, sorry.
