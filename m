From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: filter: Just In Time compiler
Date: Wed, 20 Apr 2011 01:14:54 -0700 (PDT)
Message-ID: <20110420.011454.226757908.davem@davemloft.net>
References: <1302797147.3248.32.camel@edumazet-laptop>
	<4DAE8E47.7040409@redhat.com>
	<1303286878.3186.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avi@redhat.com, hagen@jauu.net, netdev@vger.kernel.org,
	acme@infradead.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34381
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750768Ab1DTIP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:15:29 -0400
In-Reply-To: <1303286878.3186.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Apr 2011 10:07:58 +0200

> No problem, I'll wait your work on this then.

Don't, please resubmit your BPF jit code so I can apply it.

Waiting for some userspace pie-in-the-sky based solution, and blocking
this perfectly functional thing we have now meanwhile, is not
reasonable.

We're pragmatic, not perfectionists.

Thanks Eric.
