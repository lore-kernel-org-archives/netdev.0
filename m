From: Bill Fink <billfink@mindspring.com>
Subject: Re: [RFC 00/72] Organize/Move of the Ethernet drivers in
 drivers/net/
Date: Sun, 26 Jun 2011 03:54:43 -0400
Message-ID: <20110626035443.754ae57d.billfink@mindspring.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:44985 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751070Ab1FZIF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 04:05:28 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jun 2011, Jeff Kirsher wrote:

> The following series is the first attempt to organize the drivers/net
> directory.  This process was started a year ago, and the emphasis was
> on making the drivers/net/ easier to maintain and to group similar
> drivers into the appropriate sub-directory.
> 
> The next steps are to move all the FIDDI drivers into drivers/net/fiddi,
> and like so.  In addition, look at splitting the PS3 driver so that the
> wireless portion can be moved into /drivers/net/wireless.

That should be FDDI, not FIDDI.

		-Bill
