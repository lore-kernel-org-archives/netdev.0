From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: fixed missed rps_unlock
Date: Mon, 05 Apr 2010 14:37:29 -0700 (PDT)
Message-ID: <20100405.143729.10239597.davem@davemloft.net>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49014
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756396Ab0DEVh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:37:26 -0400
In-Reply-To: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 Apr 2010 14:30:58 -0700 (PDT)

> Fix spin_unlock_irq which needs to be rps_unlock.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
