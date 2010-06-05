From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] syncookies: update mss tables
Date: Sat, 05 Jun 2010 02:53:52 -0700 (PDT)
Message-ID: <20100605.025352.200385354.davem@davemloft.net>
References: <1275561837-24269-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46375
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932709Ab0FEJxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:53:42 -0400
In-Reply-To: <1275561837-24269-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  3 Jun 2010 12:43:57 +0200

> - ipv6 msstab: account for ipv6 header size
> - ipv4 msstab: add mss for Jumbograms.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks for doing this.
