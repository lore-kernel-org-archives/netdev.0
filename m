From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: don't broadcast PAUSE frames to macvlan devices
Date: Wed, 26 Nov 2008 15:31:01 -0800 (PST)
Message-ID: <20081126.153101.72068824.davem@davemloft.net>
References: <492D70E2.2040105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752553AbYKZXbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:31:02 -0500
In-Reply-To: <492D70E2.2040105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 26 Nov 2008 16:53:06 +0100

>     macvlan: don't broadcast PAUSE frames to macvlan devices
>     
>     PAUSE frames are only relevant for the real device, broadcasting them
>     to all macvlan devices can cause a significant load increase.
>     
>     Reported-by: Ben Greear <greearb@candelatech.com>
>     Tested-by: Ben Greear <greearb@candelatech.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
