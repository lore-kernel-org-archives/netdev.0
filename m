From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 10:21:55 -0700
Message-ID: <20071002172155.GP17418@bitmover.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <4702766E.80202@candelatech.com> <20071002171154.GM17418@bitmover.com> <47027D80.4070506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43532 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755773AbXJBRVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 13:21:55 -0400
Content-Disposition: inline
In-Reply-To: <47027D80.4070506@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'm currently on 2.6.20, and have also tried 10gbe nics on 2.6.23 with

My guess is that it is a bug in the debian 2.6.18 kernel.

> Have you tried something like ttcp, iperf, or even regular ftp?

Yeah, I've factored out the code since BitKeeper, my test program,
and John's test program all exhibit the same behaviour.  Also switched
switches.

> Checked your nics to make sure they have no errors and are negotiated
> to full duplex?

Yup and yup.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
