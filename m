From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff.h: Fix comment for NET_IP_ALIGN
Date: Tue, 14 Jul 2009 12:36:17 -0700 (PDT)
Message-ID: <20090714.123617.200329304.davem@davemloft.net>
References: <1247561296-25010-1-git-send-email-klto@zhaw.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: klto@zhaw.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756091AbZGNTgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:36:13 -0400
In-Reply-To: <1247561296-25010-1-git-send-email-klto@zhaw.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <klto@zhaw.ch>
Date: Tue, 14 Jul 2009 10:48:16 +0200

> Use the correct function call for skb_reserve in the comment for
> NET_IP_ALIGN.
> 
> Signed-off-by: Tobias Klauser <klto@zhaw.ch>

Applied, thanks.
