From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6 addrlabel: permit deletion of labels assigned
 to removed dev
Date: Mon, 17 May 2010 17:08:24 -0700 (PDT)
Message-ID: <20100517.170824.112586965.davem@davemloft.net>
References: <1273267893-22485-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090Ab0ERAIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:08:15 -0400
In-Reply-To: <1273267893-22485-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri,  7 May 2010 23:31:33 +0200

> as addrlabels with an interface index are left alone when the
> interface gets removed this results in addrlabels that can no
> longer be removed.
> 
> Restrict validation of index to adding new addrlabels.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
