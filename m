From: David Miller <davem@davemloft.net>
Subject: Re: [GENETLINK]: Fix adjustment of number of multicast groups
Date: Tue, 24 Jul 2007 15:34:02 -0700 (PDT)
Message-ID: <20070724.153402.97293516.davem@davemloft.net>
References: <20070724094514.GD9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757336AbXGXWeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 18:34:03 -0400
In-Reply-To: <20070724094514.GD9285@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 24 Jul 2007 11:45:14 +0200

> The current calculation of the maximum number of genetlink
> multicast groups seems odd, fix it.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
