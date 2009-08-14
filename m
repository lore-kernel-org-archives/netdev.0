From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] pppoe: fix race at init time
Date: Fri, 14 Aug 2009 20:42:42 +0400
Message-ID: <20090814164242.GA5169@lenovo>
References: <20090728184834.GD4678@lenovo> <43d009740907282055t44bfa2e2md3afa514d4b2d7e6@mail.gmail.com> <20090729144642.GA5094@lenovo> <20090812.164007.240124819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: for.poige+bugzilla.kernel.org@gmail.com, eric.dumazet@gmail.com,
	xemul@openvz.org, akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:8929 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932716AbZHNQmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 12:42:46 -0400
Received: by ey-out-2122.google.com with SMTP id 22so345566eye.37
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 09:42:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090812.164007.240124819.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[David Miller - Wed, Aug 12, 2009 at 04:40:07PM -0700]
... 
| Still no feedback on this one, but it looks totally correct to me.
| 
| So I've applied it to net-next-2.6 so that it doesn't get lost and if
| it turns out we need it to actually fix a user reported bug we can
| toss it into net-2.6 too.
| 

Thanks David!

	-- Cyrill
