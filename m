From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: [br2684] allow routed mode operation again
Date: Tue, 08 Dec 2009 20:22:55 -0800 (PST)
Message-ID: <20091208.202255.222244513.davem@davemloft.net>
References: <200912042055.nB4Kto8M008310@cmf.nrl.navy.mil>
	<200912042106.nB4L6Wc7012919@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mfuentes@agenciaefe.com
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50898
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756670AbZLIEWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:22:48 -0500
In-Reply-To: <200912042106.nB4L6Wc7012919@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Date: Fri, 04 Dec 2009 16:06:32 -0500

> sorry this should be Signed-off-by me instead of manuel.  *sigh*
> 
> From: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> 
> atm: [br2684] allow routed mode operation again
> 
> in routed mode, we don't have a hardware address so netdev_ops doesnt
> need to validate our hardware address via .ndo_validate_addr
> 
> Reported-by: Manuel Fuentes <mfuentes@agenciaefe.com>
> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
