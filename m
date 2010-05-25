From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] macvlan: do a proper cleanup in
 macvlan_common_newlink()
Date: Mon, 24 May 2010 18:41:37 -0700 (PDT)
Message-ID: <20100524.184137.44120295.davem@davemloft.net>
References: <20100524155857.GO2810@psychotron.lab.eng.brq.redhat.com>
	<20100524170224.GA2816@psychotron.redhat.com>
	<4BFACBE0.4020109@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754449Ab0EYBl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 21:41:28 -0400
In-Reply-To: <4BFACBE0.4020109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 24 May 2010 20:56:32 +0200

> Jiri Pirko wrote:
>> Mon, May 24, 2010 at 05:58:58PM CEST, jpirko@
>> Subject: [PATCH net-2.6] macvlan: do proper cleanup in macvlan_common_newlink() V2
>> 
>> Fixes possible memory leak.
> 
> Looks good, thanks.
> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
