From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 23:49:14 +0200
Message-ID: <20110516214914.GJ3290@nuttenaction>
References: <201105141938.28344.v13@v13.gr>
 <1305464176.3120.113.camel@edumazet-laptop>
 <1305466542.3120.129.camel@edumazet-laptop>
 <201105151808.39231.v13@v13.gr>
 <1305475310.3120.146.camel@edumazet-laptop>
 <20110516213336.GD3290@nuttenaction>
 <1305581918.9466.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefanos Harhalakis <v13@v13.gr>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:44169 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756422Ab1EPVtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:49:16 -0400
Content-Disposition: inline
In-Reply-To: <1305581918.9466.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-05-16 23:38:38 [+0200]:

>Check v2 of patch, it is fine, small, fast ;)

Eric, I trust you! ;-)

>By the way, you dont want to know how many cpu cycles we spend in IP
>defrag functions... Really its insane.

I can image it! I wanted to point out to the fact that gcc's (and other compiler
too) jump table optimizations are not advantageous than a few years ago.
Maybe jump table optimizations are a relict some decades ago ...

Hagen
