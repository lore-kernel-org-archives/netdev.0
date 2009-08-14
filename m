From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: remove restarting workaround flag
Date: Fri, 14 Aug 2009 16:38:41 -0700 (PDT)
Message-ID: <20090814.163841.01993410.davem@davemloft.net>
References: <20090814151511.992669598@vyatta.com>
	<20090814.154154.53636130.davem@davemloft.net>
	<20090814163317.3c5b5942@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55311
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755816AbZHNXia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:38:30 -0400
In-Reply-To: <20090814163317.3c5b5942@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 14 Aug 2009 16:33:17 -0700

> The whole restarting flag was introduced by Mike McCormack
> and was a temporary duct tape patch around issues with transmits
> inflight during restart. The problems it was covering are now
> fixed and the code should have been reverted.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
