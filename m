From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] dsa/mv88e6131: fix unknown multicast/broadcast
 forwarding on mv88e6085
Date: Tue, 26 Apr 2011 16:57:40 +0200
Message-ID: <20110426145740.GL1897@wantstofly.org>
References: <1303818341-13839-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:64066 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756671Ab1DZOys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 10:54:48 -0400
Content-Disposition: inline
In-Reply-To: <1303818341-13839-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 01:45:41PM +0200, Peter Korsgaard wrote:

> The 88e6085 has a few differences from the other devices in the port
> control registers, causing unknown multicast/broadcast packets to get
> dropped when using the standard port setup.
> 
> At the same time update kconfig to clarify that the mv88e6085 is now
> supported.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Assuming that you've tested this.. :)

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
