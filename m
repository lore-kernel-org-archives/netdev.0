From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 02 Sep 2010 09:30:23 -0700 (PDT)
Message-ID: <20100902.093023.71114413.davem@davemloft.net>
References: <20100901145554.4f5abd80@nehalam>
	<20100902091839.GB6246@ff.dom.local>
	<20100902125326.GD8775@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702Ab0IBQaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:30:07 -0400
In-Reply-To: <20100902125326.GD8775@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 2 Sep 2010 12:53:26 +0000

> Stephen, after Eric's explanation, I really think this patch was a bad
> idea, and I apologize my false opinion started this.
> 
> I hope David, will revert this patch, please.

Ok, now that I've reread everything over I agree, I'll revert the
sky2 change, thanks.
