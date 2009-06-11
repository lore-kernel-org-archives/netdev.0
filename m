From: David Miller <davem@davemloft.net>
Subject: Re: WoL and r8169
Date: Thu, 11 Jun 2009 02:54:46 -0700 (PDT)
Message-ID: <20090611.025446.235813465.davem@davemloft.net>
References: <20090608215301.GA28044@electric-eye.fr.zoreil.com>
	<20090610102940.87FE633C023@tippex.mynet.homeunix.org>
	<20090610230116.GA23440@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aeriksson@fastmail.fm, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758659AbZFKJyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:54:43 -0400
In-Reply-To: <20090610230116.GA23440@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 11 Jun 2009 01:01:16 +0200

> Anders Eriksson <aeriksson@fastmail.fm> :
> [...]
>> Yes! That diff made the trick for WoL on magic package on my 2.6.30-rc6
>> kernel. Is it sent to Linus for -final?
> 
> No but it does not preclude it being properly submitted thereafter then
> for -stable.

Right.  Feel free to send me a formal submission of this fix with
proper changelog and signoffs.

Thanks!
