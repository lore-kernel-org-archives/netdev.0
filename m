From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 12:39:56 -0700
Message-ID: <20060919123956.38e87c08@localhost.localdomain>
References: <20060918.115309.88343320.davem@davemloft.net>
	<20060918195224.GA26585@outpost.ds9a.nl>
	<20060918214104.3824a2e2@localhost.localdomain>
	<20060919.123352.124082859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43137 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751994AbWISTkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:40:05 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060919.123352.124082859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It built (and ran) for me. But that was on a different machine.
Perhaps there was some git confusion, I'll go back to using quilt
it gives me less grief.

-- 
Stephen Hemminger <shemminger@osdl.org>
