From: David Miller <davem@davemloft.net>
Subject: Re: netconsole still hangs
Date: Thu, 13 Mar 2008 00:12:55 -0700 (PDT)
Message-ID: <20080313.001255.01742148.davem@davemloft.net>
References: <20080312165717.c0879b1d.akpm@linux-foundation.org>
	<20080312.231053.216645957.davem@davemloft.net>
	<20080312235205.dcec2d35.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750783AbYCMHMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 03:12:46 -0400
In-Reply-To: <20080312235205.dcec2d35.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 12 Mar 2008 23:52:05 -0700

> Whine.  I can _trivially_ reproduce this stuff on the two machines which I
> tried it on.  Has anyone over in net land actually expended some cycles
> trying to reproduce these things?

I would if I weren't in Japan currently giving presentations
and attending BoF's, so whining at me isn't very productive.

I asked you to do the bisect check since that's the fastest
way forward at the current time.
