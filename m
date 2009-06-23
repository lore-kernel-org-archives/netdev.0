From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Fix a race condition in sky2_poll
Date: Tue, 23 Jun 2009 16:45:44 -0700 (PDT)
Message-ID: <20090623.164544.114856885.davem@davemloft.net>
References: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755277AbZFWXpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 19:45:40 -0400
In-Reply-To: <392fb48f0906200101y5c83e853w170829f2ce40b274@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Sat, 20 Jun 2009 17:01:25 +0900

> Clear interrupt only when the status buffer is fully drained,
> Make sure to clear interrupt when work_done == work_limit
>  and the buffer is drained.

Stephen's away on vacation for a bit so I wonder what to do
about these two sky2 patches of your's.

I guess it's not extremely urgent and we can thus wait for him
to get back in a week or so and review your patches.
