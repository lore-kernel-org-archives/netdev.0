From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Wed, 10 Jul 2013 21:29:29 +0200
Message-ID: <20130710192929.GA28777@electric-eye.fr.zoreil.com>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
 <20130710134104.GA4086@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44921 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab3GJT3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 15:29:39 -0400
Content-Disposition: inline
In-Reply-To: <20130710134104.GA4086@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek <pavel@ucw.cz> :
[...]
> Actually, receiving is slow. Transmit is ok. "duo" is "bad" machine
> with RTL card.

No hint from the hardware statistics (ethtool -S eth0) ?

-- 
Ueimor
