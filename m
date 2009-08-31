From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: use correct NET_RX_ return values
Date: Sun, 30 Aug 2009 22:13:57 -0700 (PDT)
Message-ID: <20090830.221357.220991563.davem@davemloft.net>
References: <4A995B15.4020303@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36653
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753435AbZHaFNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:13:43 -0400
In-Reply-To: <4A995B15.4020303@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Sat, 29 Aug 2009 18:45:09 +0200

> Dropped skb's should be documented by an appropriate return value.
> Use the correct NET_RX_DROP and NET_RX_SUCCESS values for that reason.
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

Applied, thanks.
