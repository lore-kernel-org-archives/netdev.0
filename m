From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.23-rc8 network problem. Mem leak? ip1000a?
Date: Tue, 8 Jan 2008 08:51:26 +0100
Message-ID: <20080108075126.GA21412@electric-eye.fr.zoreil.com>
References: <20070930022347.37514be3.akpm@linux-foundation.org> <20080108065211.25290.qmail@science.horizon.com> <20080107.230709.216880096.davem@davemloft.net> <20080107.231447.08811264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45359 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750907AbYAHIDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 03:03:47 -0500
Content-Disposition: inline
In-Reply-To: <20080107.231447.08811264.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> I invested 30 seconds of code reading to figure out the leak.  A much
> better investment of time than adding bogus comments to the Kconfig
> help text don't you think? :-)

Thanks for the hint David.

I'll roll up a patch for it after the day work.

-- 
Ueimor
