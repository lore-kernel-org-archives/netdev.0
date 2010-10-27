From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 11:35:37 -0700 (PDT)
Message-ID: <20101027.113537.15227235.davem@davemloft.net>
References: <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
	<20101027.105047.183059900.davem@davemloft.net>
	<AANLkTi=jDDDk15KDhsC=qTnmgU5Urhc9LTrROkFOsY_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, security@kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755271Ab0J0SfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:35:14 -0400
In-Reply-To: <AANLkTi=jDDDk15KDhsC=qTnmgU5Urhc9LTrROkFOsY_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 27 Oct 2010 14:27:13 -0400

> I've got some patches from Al that I'm pre-reviewing/testing
> before spamming everyone with them (will send within 24h, if
> that is OK).   Anyway, in the above, does it make sense to
> check for the overflow incrementally, i.e. something like this?

Can you please not work on this in private?  That's the only reason
we have duplicated work here.
