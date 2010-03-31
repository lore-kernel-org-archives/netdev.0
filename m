From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] cxgb4: Add main driver file and driver Makefile
Date: Wed, 31 Mar 2010 14:13:25 -0700 (PDT)
Message-ID: <20100331.141325.107258329.davem@davemloft.net>
References: <20100330141904.5236fe44@nehalam>
	<20100330.225042.107712654.davem@davemloft.net>
	<4BB3A301.3090100@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dm@chelsio.com, netdev@vger.kernel.org
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47634
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758176Ab0CaVNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 17:13:24 -0400
In-Reply-To: <4BB3A301.3090100@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 31 Mar 2010 14:31:13 -0500

> This sounds interesting.  Dave, how would you envision the ethtool
> interface for this?  A new modifier to --statistics?  Like: 'ethtool
> --statistics ethX viewname' where viewname could maybe be passed to
> the driver to allow arbitrary views?  Or something else?

I really don't care much about the userland side, I'm only
interested in how you implement this in the kernel :-)
