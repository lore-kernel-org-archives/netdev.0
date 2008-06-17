From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] bridge: use statistics in net_device
Date: Tue, 17 Jun 2008 16:35:27 -0700
Message-ID: <20080617163527.40c9ecd3@extreme>
References: <20080617165211.615620784@vyatta.com>
	<20080617165223.258482526@vyatta.com>
	<20080617.161409.132612527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:35292 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759573AbYFQXf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 19:35:29 -0400
In-Reply-To: <20080617.161409.132612527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jun 2008 16:14:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 17 Jun 2008 09:52:14 -0700
> 
> > Move statistics to net_device structure. Also, update last_rx on bridge
> > device (even though only bonding seems to use it).
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> This patch doesn't apply even remotely to anything I have in my tree.
> What did you generate this against?


Patch was against 2.6.26-rc6
