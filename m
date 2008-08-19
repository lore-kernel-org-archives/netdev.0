From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 19 Aug 2008 13:14:54 -0700 (PDT)
Message-ID: <20080819.131454.223684377.davem@davemloft.net>
References: <20080819.041706.261399060.davem@davemloft.net>
	<alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753953AbYHSUOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 16:14:54 -0400
In-Reply-To: <alpine.LFD.1.10.0808190952000.3324@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 19 Aug 2008 10:03:07 -0700 (PDT)

> For example, those BT updates looked in no way like regression fixes. So 
> what the f*ck were they doing there? And why do you think all those driver 
> updates cannot cause new regressions? 

The BT bits were the only part I really considered borderline,
and I was going to push back on Marcel.

But to be honest, I haven't seen bluetooth updates from him
for such a long time I felt that being strict here would just
exacerbate the problem.

Guess I was wrong.
