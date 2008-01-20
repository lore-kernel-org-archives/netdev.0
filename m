From: Andi Kleen <ak@suse.de>
Subject: Re: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 21:58:41 +0100
Message-ID: <200801202158.42093.ak@suse.de>
References: <200801202053.30386.ak@suse.de> <20080120200109.GA31876@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:55474 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755568AbYATU6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 15:58:44 -0500
In-Reply-To: <20080120200109.GA31876@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> It seems to have stopped when i stopped using ipsec and started using
> vpnc.

Kernel ipsec was active yes. However I normally don't see it although
it is often active, that was the first time I think

(except long ago) 

> (but no firm info - this was sporadic - happened every few months 
> or so) Are you using ipsec and dynamic IPs by any chance?

and the ISP uses dynamic IPs.

-Andi
