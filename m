From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] div64_64 consolidate (rev3)
Date: Sun, 04 Mar 2007 16:17:40 -0800 (PST)
Message-ID: <20070304.161740.30185028.davem@davemloft.net>
References: <20070302172920.201fe5af@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52047
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752559AbXCEARm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 19:17:42 -0500
In-Reply-To: <20070302172920.201fe5af@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 2 Mar 2007 17:29:20 -0800

> Here is the current version of the 64 bit divide common code.
> Since it is used by three times by networking code, can we put it net-2.6.22 tree?
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.22, thanks.
