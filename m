From: David Miller <davem@davemloft.net>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 03:49:33 -0700 (PDT)
Message-ID: <20080922.034933.119934091.davem@davemloft.net>
References: <87zlmhs7we.fsf@basil.nowhere.org>
	<48C6C300.4050102@redhat.com>
	<20080909.125934.150042096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org
To: csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753025AbYIVKtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 06:49:46 -0400
In-Reply-To: <20080909.125934.150042096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 09 Sep 2008 12:59:34 -0700 (PDT)

> 
> Still waiting for your test program and example traces Chris.
> 
> Until I see that there really isn't anything more I can contribute
> concretely to this discussion.

Ping, still waiting for this...  Can you provide the test case,
perhaps sometime this year? :-)

I'll try to figure out why Andi's patch doesn't behave as expected.
I suspect you may have a bum build if the sysctl values are coming
up as zero as that's completely impossible as far as I can tell.

If something so fundamental as that isn't behaving properly, all
bets are off for anything else you try to use when having that
patch applied.
