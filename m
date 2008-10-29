From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] macvlan: add support for ethtool get settings
Date: Wed, 29 Oct 2008 15:32:01 -0700 (PDT)
Message-ID: <20081029.153201.52883553.davem@davemloft.net>
References: <20081029125343.695eeb3c@extreme>
	<4908CF28.4060704@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752112AbYJ2Wc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 18:32:27 -0400
In-Reply-To: <4908CF28.4060704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 29 Oct 2008 22:01:28 +0100

> Stephen Hemminger wrote:
> > If macvlan's are used, it is useful to propgate speed and other settings
> > from underlying device up for application usage.
> >   
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
