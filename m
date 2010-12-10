From: David Miller <davem@davemloft.net>
Subject: Re: Misuse of LRO, how widespread
Date: Fri, 10 Dec 2010 15:03:45 -0800 (PST)
Message-ID: <20101210.150345.57479468.davem@davemloft.net>
References: <1291667408.3443.10.camel@bwh-desktop>
	<20101206143301.6b6dd17d@nehalam>
	<1291674912.5405.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, olof@lixom.net, divy@chelsio.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45089
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753945Ab0LJXDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:03:18 -0500
In-Reply-To: <1291674912.5405.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 06 Dec 2010 22:35:12 +0000

> On Mon, 2010-12-06 at 14:33 -0800, Stephen Hemminger wrote:
>> How about this?
>> 
>> Subject: sfc: convert references to LRO to GRO
>> 
>> This driver now uses Generic Receive Offload, not the older LRO.
>> Change references to LRO in names and comments.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6, thanks!
