From: David Miller <davem@davemloft.net>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Wed, 02 Apr 2008 22:28:46 -0700 (PDT)
Message-ID: <20080402.222846.92587028.davem@davemloft.net>
References: <47F15200.3060706@linux.intel.com>
	<47F46945.40500@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751996AbYDCF2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:28:45 -0400
In-Reply-To: <47F46945.40500@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@linux.intel.com>
Date: Wed, 02 Apr 2008 22:21:09 -0700

> It would be not so nice to ship a 2.6.25 that triggers these frequently,
> it has the risk of causing many user bugreports to this list and other
> places...

I wouldn't call it frequently, on at least an individual basis,
because nobody we try to get feedback from can reproduce this
reliably.  That's the only reason this isn't fixed yet, despite
all of Ilpo's efforts.

