From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 23:39:13 +0100
Message-ID: <20080327223913.GB3596@ami.dom.local>
References: <20080327124928.GE2845@ami.dom.local> <200803272256.50454.rjw@sisk.pl> <20080327222248.GA3596@ami.dom.local> <20080327.152218.235944668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rjw@sisk.pl, a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:58266 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045AbYC0Wex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 18:34:53 -0400
Received: by ug-out-1314.google.com with SMTP id z38so557770ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 15:34:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080327.152218.235944668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 03:22:18PM -0700, David Miller wrote:
...
> Instead of going back and forth like this can someone post
> just take it upon themselves to post such an obvious patch
> already :-)
> 
> All of this "he'll do it, she'll do it" just wastes time.

Right! She or he should also remember to add Peter's lockup
scenario and his signed-off-by...

Jarek P.
