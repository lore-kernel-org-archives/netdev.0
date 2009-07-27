From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add some function overview comments in tcp_input.c
Date: Sun, 26 Jul 2009 19:23:21 -0700 (PDT)
Message-ID: <20090726.192321.257422911.davem@davemloft.net>
References: <20090724094719.GA19200@basil.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754914AbZG0CXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:23:14 -0400
In-Reply-To: <20090724094719.GA19200@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 24 Jul 2009 11:47:19 +0200

> Add some function overview comments in tcp_input.c
> 
> Only partial so far. I didn't attempt to accurately comment
> the SACK machinery and the congestion state machine. 
> 
> I also fixed the grammar in one or two other comments
> (but still trying to keep the authentic "ANK language" @)
> 
> No code changes.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Most of your comments sound exactly the same as what I
hear when I say the function's name out loud.

That's worse than wasted space.

What's the chapter from The Practice of Programming where
they advise against this with a bunch of amusing examples?
:-)

I'm not applying this, sorry.

