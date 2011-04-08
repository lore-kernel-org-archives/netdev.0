From: Kees Cook <kees.cook@canonical.com>
Subject: Re: shutdown(2) does not fully shut down socket any more
Date: Fri, 8 Apr 2011 15:30:04 -0700
Message-ID: <20110408223004.GY4050@outflux.net>
References: <20110408221046.GW4050@outflux.net>
 <20110408.152427.193714809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.outflux.net ([198.145.64.163]:42406 "EHLO smtp.outflux.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256Ab1DHWaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 18:30:06 -0400
Content-Disposition: inline
In-Reply-To: <20110408.152427.193714809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Apr 08, 2011 at 03:24:27PM -0700, David Miller wrote:
> Eric Dumazet will be working on fixing this, see:
> 
> http://marc.info/?l=linux-netdev&m=130176733401613&w=2
> 
> And Stephem Hemminger already forward that bugzilla entry here
> at few days ago.

Ah! Thanks, I didn't noticed that; I saw no activity on the bugzilla entry,
so I thought it hadn't been seen yet.

-Kees

-- 
Kees Cook
Ubuntu Security Team
