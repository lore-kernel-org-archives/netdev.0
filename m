From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/3][ARP] Minus one level of indentation in
 arp_req_set
Date: Wed, 05 Dec 2007 21:19:55 -0800 (PST)
Message-ID: <20071205.211955.114689834.davem@davemloft.net>
References: <4756DC96.7050700@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751121AbXLFFT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 00:19:56 -0500
In-Reply-To: <4756DC96.7050700@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 05 Dec 2007 20:15:02 +0300

> The ATF_PUBL requests are handled completely separate from
> the others. Emphasize it with a separate function. This also
> reduces the indentation level.
> 
> The same issue exists with the arp_delete_request, but
> when I tried to make it in one patch diff produced completely
> unreadable patch. So I split it into two, but they may be 
> done with one commit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
