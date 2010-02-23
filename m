From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/1] xfrm: clone mark when cloning policy
Date: Tue, 23 Feb 2010 15:10:27 -0800 (PST)
Message-ID: <20100223.151027.99318910.davem@davemloft.net>
References: <sk-mark-clone>
	<1266966484-1750-1-git-send-email-hadi@cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51983
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754531Ab0BWXKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 18:10:10 -0500
In-Reply-To: <1266966484-1750-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 23 Feb 2010 18:08:04 -0500

> From: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> When we clone the SP, we should also clone the mark.
> Useful for socket based SPs.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks.
