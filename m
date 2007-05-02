From: David Miller <davem@davemloft.net>
Subject: Re: AF_RXPC build failure
Date: Wed, 02 May 2007 15:42:31 -0700 (PDT)
Message-ID: <20070502.154231.27808792.davem@davemloft.net>
References: <20070502153418.2cc27f4f@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767123AbXEBWma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:42:30 -0400
In-Reply-To: <20070502153418.2cc27f4f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 2 May 2007 15:34:18 -0700

> Looks like new RXRPC code depends on key storage but doesn't
> select it.

Yes I have some patches from David Howells to deal with this,
will push those soon.

Thanks for reporting.
