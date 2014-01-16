From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 00/13] Assorted mvneta fixes and improvements
Date: Thu, 16 Jan 2014 08:22:44 +0100
Message-ID: <20140116072244.GA15879@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55500 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbaAPHWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:22:50 -0500
Content-Disposition: inline
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 08:20:06AM +0100, Willy Tarreau wrote:
> Hi,
> 
> this series provides some fixes for a number of issues met with the
> mvneta driver, then adds some improvements. Patches 1-5 are fixes
> and would be needed in 3.13 and likely -stable. The next ones are
> performance improvements and cleanups :

I just wanted to make it clear that the whole series is desired for net-next.

Thanks,
Willy
