From: David Miller <davem@davemloft.net>
Subject: Re: [net-next pull-request] Intel Wired LAN Driver Updates
Date: Wed, 17 Nov 2010 10:01:19 -0800 (PST)
Message-ID: <20101117.100119.71117424.davem@davemloft.net>
References: <1289969989.2815.10.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933795Ab0KQSAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 13:00:54 -0500
In-Reply-To: <1289969989.2815.10.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 16 Nov 2010 20:59:49 -0800

> Here is a batch of fixes/cleanups intended for 2.6.38.  In the mix is added
> support for x540 10GbE MAC.  A large part of the changes are ixgbe cleanup
> patches by Alex.
> 
> Please let me know if there are problems.

Pulled, thanks Jeff.

But in the future you'll need to still post the patches you're asking
me to merge to the list.  Usually folks do this by posting something
like a "Subject: [PATCH 0/N] Intel Wired Lan Driver Updates"
thread-leading posting which contains an overall description of the
changes, as well as the pull request.  This is followed-up with the
actual patches.

This way people can review the changes and reply to any issues they
have on-list with a simple reply to the patch in question.

Thanks.
