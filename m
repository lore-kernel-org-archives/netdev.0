From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26][DCCP]: Fix comment about control sockets.
Date: Mon, 14 Apr 2008 02:38:54 -0700 (PDT)
Message-ID: <20080414.023854.263010240.davem@davemloft.net>
References: <48032593.3080409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbYDNJi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 05:38:57 -0400
In-Reply-To: <48032593.3080409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Apr 2008 13:36:19 +0400

> These sockets now have a bit other names and are no longer global.
> 
> Shame on me, I haven't provided a good comment for this when
> sending DCCP netnsization patches.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
