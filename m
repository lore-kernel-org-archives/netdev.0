From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] [NIU] Resend: Determine the # of ports from the
 card's VPD data
Date: Fri, 09 May 2008 14:56:31 -0700 (PDT)
Message-ID: <20080509.145631.147073993.davem@davemloft.net>
References: <200805092154.m49LsQfb053337@sr1-umpk-37.sfbay.sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matheos.worku@sun.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51457
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbYEIV4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 17:56:37 -0400
In-Reply-To: <200805092154.m49LsQfb053337@sr1-umpk-37.sfbay.sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <matheos.worku@sun.com>
Date: Fri, 9 May 2008 11:08:06 -0700

> Determine the number of physical ports from the card's VPD data.
> Previous fix failed on Maramba platform which doesn't have the
> "board-model" property. This fix uses the "model" property which
> exists on all cards and Neptune based motherboards.
> 
> cstyle cleanup included. 
> 
> Signed-off-by: Matheos Worku <matheos.worku@sun.com>

Applied, thanks a lot Matheos.
