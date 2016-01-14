From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] r8152 add Microsoft Dock IDs
Date: Thu, 14 Jan 2016 19:16:25 +0100
Message-ID: <20160114181625.GK19773@lunn.ch>
References: <20160114.184626.1327276960383833164.rene@exactcode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Rene Rebe <rene@exactcode.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54371 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756533AbcANSQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2016 13:16:27 -0500
Content-Disposition: inline
In-Reply-To: <20160114.184626.1327276960383833164.rene@exactcode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 14, 2016 at 06:46:26PM +0100, Rene Rebe wrote:
> Hi David,
> (my appologies for wasting your time with this noise)
> 
> rebased against your netdev git, and sent with Mew:

Hi Rene

So, slowly getting better. However, go read
Documentation/SubmittingPatches

Read the bit about the "---" marker.

netdev also has a few additional rules, which are not documented in
SubmittingPatches.

In the subject line, you should include which tree this patch is
supposed to be applied to. In this case, it is net-next. So you
subject line should be

Subject: [PATCH net-next] r8152 add Microsoft Dock IDs

and obviously, your patch needs to cleanly apply to net-next, not some
other random tree.

The other rule which is relevant at the moment, is that net-next is
closed, because the merge window is open. So please wait about 12 days
for net-next to reopen. David will probably send an email saying he is
ready to accept new patches.

      Andrew
