From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] br2684: get rid of broken header code.
Date: Wed, 17 Oct 2007 19:39:31 -0700 (PDT)
Message-ID: <20071017.193931.89038566.davem@davemloft.net>
References: <20071016143850.5fcd5345@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35278
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755059AbXJRCjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:39:32 -0400
In-Reply-To: <20071016143850.5fcd5345@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 16 Oct 2007 14:38:50 -0700

> Recent header_ops change would break the following dead
> code in br2684. Maintaining conditonal code in mainline is wrong.
> 
> "Do, or do not. There is no 'try.'" 
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
