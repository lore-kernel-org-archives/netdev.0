From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] dsa/mv88e6131: add support for mv88e6085 switch
Date: Tue, 5 Apr 2011 15:39:44 +0200
Message-ID: <20110405133944.GG22881@wantstofly.org>
References: <1302008636-6544-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:50243 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab1DENhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 09:37:53 -0400
Content-Disposition: inline
In-Reply-To: <1302008636-6544-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 03:03:56PM +0200, Peter Korsgaard wrote:

> The mv88e6085 is identical to the mv88e6095, except that all ports are
> 10/100 Mb/s, so use the existing setup code except for the cpu/dsa speed
> selection in _setup_port().
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

I don't have access to DSA chip docs anymore, but assuming that you've
tested this:

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
