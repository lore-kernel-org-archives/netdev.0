From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: add DRR scheduler
Date: Thu, 20 Nov 2008 12:06:47 +0000
Message-ID: <20081120120647.GC5275@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081120115137.GB5275@ff.dom.local> <492550D3.7060602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:60694 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbYKTMGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:06:54 -0500
Received: by ug-out-1314.google.com with SMTP id 39so252567ugf.37
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2008 04:06:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <492550D3.7060602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2008 at 12:58:11PM +0100, Patrick McHardy wrote:
...
> Its trivial to use though, these is only a single optional parameter,
> the quantum.

OK, but if you advertise this as a "flexible replacement for SFQ"
sb. could be mislead, so I mean at least a simple example of such
replacement.

Jarek P.
