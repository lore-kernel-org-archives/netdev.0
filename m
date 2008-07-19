From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: packet: add PACKET_RESERVE sockopt
Date: Fri, 18 Jul 2008 18:05:35 -0700 (PDT)
Message-ID: <20080718.180535.239606663.davem@davemloft.net>
References: <4880D96E.4060708@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbYGSBFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:05:35 -0400
In-Reply-To: <4880D96E.4060708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 18 Jul 2008 19:57:02 +0200

>     packet: add PACKET_RESERVE sockopt
>     
>     Add new sockopt to reserve some headroom in the mmaped ring frames in
>     front of the packet payload. This can be used f.i. when the VLAN header
>     needs to be (re)constructed to avoid moving the entire payload.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
