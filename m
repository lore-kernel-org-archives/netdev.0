From: Francois Romieu <romieu@zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Mon, 11 Mar 2013 01:02:16 +0100
Message-ID: <20130311000216.GA31808@zoreil.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pulsar.zoreil.com ([83.167.33.49]:56411 "EHLO pulsar.zoreil.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753259Ab3CKAI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 20:08:56 -0400
Content-Disposition: inline
In-Reply-To: <20130309064647.GC4984@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> While we can rely on the retry system to paper over this regression, the
> behaviour of earlier kernels suggests that there is a real issue at play. 
> Is there any chance that this can be looked at ?

Yes.

You'll have to be a bit patient since I still have to spend a pair of non
worked hours on a compromised system. :o/

Take it for what it's worth but I don't test much with PREEMPT, NOHZ or
SLUB and I never tried all those at the same time.

-- 
Ueimor
