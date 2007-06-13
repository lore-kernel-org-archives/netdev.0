From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: remove initial_ssthresh from Cubic
Date: Wed, 13 Jun 2007 11:46:21 -0700 (PDT)
Message-ID: <20070613.114621.85409138.davem@davemloft.net>
References: <20070613102718.61d67a36@localhost>
	<20070613.112652.112623832.davem@davemloft.net>
	<20070613113149.5cd1b11e@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, sangtae.ha@gmail.com, rhee@eos.ncsu.edu,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbXFMSqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 14:46:05 -0400
In-Reply-To: <20070613113149.5cd1b11e@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 13 Jun 2007 11:31:49 -0700

> Maybe it is time to remove BIC?

I don't see any compelling reason, the same could be said
of the other experimental protocols we include in the tree.
