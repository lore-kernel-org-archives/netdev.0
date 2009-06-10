From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WoL and r8169
Date: Thu, 11 Jun 2009 01:01:16 +0200
Message-ID: <20090610230116.GA23440@electric-eye.fr.zoreil.com>
References: <20090607214220.5101B33C013@tippex.mynet.homeunix.org> <20090608215301.GA28044@electric-eye.fr.zoreil.com> <20090610102940.87FE633C023@tippex.mynet.homeunix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Anders Eriksson <aeriksson@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50083 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756880AbZFJW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 18:59:19 -0400
Content-Disposition: inline
In-Reply-To: <20090610102940.87FE633C023@tippex.mynet.homeunix.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anders Eriksson <aeriksson@fastmail.fm> :
[...]
> Yes! That diff made the trick for WoL on magic package on my 2.6.30-rc6
> kernel. Is it sent to Linus for -final?

No but it does not preclude it being properly submitted thereafter then
for -stable.

[...]
> I tried to wake up the machine using regular tcp traffic, on the theory that 
> it's unicast and phy activity. No luck though.

Did the regular tcp traffic include a so-called magic (tcp) packet ?

-- 
Ueimor
