From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Mon, 28 Jan 2008 16:32:47 -0800 (PST)
Message-ID: <20080128.163247.199701673.davem@davemloft.net>
References: <1199403419.25262.62.camel@localhost.localdomain>
	<6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncase@xes-inc.com, jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59400
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765041AbYA2Aca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 19:32:30 -0500
In-Reply-To: <6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Mon, 28 Jan 2008 18:29:39 -0600

> Jeff, Dave, any chance we can get this one in for 2.6.25?  It will  
> allow a number of other drivers to start using PHY Lib.
> I'm sure Nate can resend if needed.

This shouldn't be a problem.

I just did my initial merge with Linus, so after he pulls
that in Jeff can merge stuff like this to me so that it
can go into my second pass.
