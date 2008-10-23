From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Wed, 22 Oct 2008 21:11:48 -0700 (PDT)
Message-ID: <20081022.211148.98722383.davem@davemloft.net>
References: <48FFBA06.50609@hp.com>
	<200810231143.22027.jk@ozlabs.org>
	<200810231434.47989.jk@ozlabs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	patchwork@ozlabs.org, mbizon@freebox.fr
To: jk@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750777AbYJWEML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 00:12:11 -0400
In-Reply-To: <200810231434.47989.jk@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Kerr <jk@ozlabs.org>
Date: Thu, 23 Oct 2008 14:34:47 +1100

> OK, patchwork didn't like that the mail had no Content-Type header, so 
> has no character set encoding defined. I've just checked-in change to 
> assume a utf-8 encoding by default:
> 
> http://git.ozlabs.org/?p=patchwork;a=commitdiff;h=d45218b2e3894211e11313820bea9f59677c4bf2
> 
> Which should mean that future patches will be accepted.

Thanks a lot for fixing this Jeremy.  I bet some other patches got
eaten by this too.

> (if you'd like me to manually re-inject that series of patches, just 
> forward the mboxes over to me)

Not needed, I'll apply Vlad's patches since I have them in my inbox.
