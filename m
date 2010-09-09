From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atlx: make strings const
Date: Wed, 08 Sep 2010 21:32:25 -0700 (PDT)
Message-ID: <20100908.213225.52201178.davem@davemloft.net>
References: <20100908151836.3c40cc81@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003Ab0IIEcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:32:07 -0400
In-Reply-To: <20100908151836.3c40cc81@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 8 Sep 2010 15:18:36 -0700

> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Chris Snook <chris.snook@gmail.com>

Applied, feel free to hit those __initconst cases too.
