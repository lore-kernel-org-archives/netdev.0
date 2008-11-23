From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139too: use err.h macros
Date: Sun, 23 Nov 2008 23:31:42 +0100
Message-ID: <20081123223142.GA2597@electric-eye.fr.zoreil.com>
References: <20081123102237.42cc99dd@extreme> <20081123183645.GA11340@havoc.gtf.org> <20081123.135311.74121589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51132 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbYKWWc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 17:32:29 -0500
Content-Disposition: inline
In-Reply-To: <20081123.135311.74121589.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Two return values without having to return it by reference
> as an argument.

It is quite common in fs/ too.

I would use it more frequently.

-- 
Ueimor
