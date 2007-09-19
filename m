From: David Miller <davem@davemloft.net>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 09:15:10 -0700 (PDT)
Message-ID: <20070919.091510.00787167.davem@davemloft.net>
References: <46F13E8B.4050309@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754930AbXISQPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:15:25 -0400
In-Reply-To: <46F13E8B.4050309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 19 Sep 2007 08:21:47 -0700

> If you think the POSIX spec is wrong (and can point to other
> implementations doing the same as Linux) let me know and I'll work on
> getting the spec changed.

The whole AF_UNSPEC thing I'm almost certain comes from BSD, which has
behaved that way for centuries.

Someone needs to cull through Steven's Volume 2 to verify this, I'm
too busy at the moment to do so myself.
