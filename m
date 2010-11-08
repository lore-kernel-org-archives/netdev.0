From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Mon, 8 Nov 2010 17:21:32 +0100
Message-ID: <20101108162132.GA32728@core.hellgate.ch>
References: <20101105104303.GA8325@core.hellgate.ch>
 <AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail17.bluewin.ch ([195.186.18.64]:30863 "EHLO
	mail17.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796Ab0KHQVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 11:21:37 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Nov 2010 11:31:56 -0700, Jesse Gross wrote:
> On Fri, Nov 5, 2010 at 3:43 AM, Roger Luethi <rl@hellgate.ch> wrote:
> > This patch adds VLAN hardware support for Rhine chips.
> 
> This uses the old interfaces for vlan acceleration.  We're working to
> switch drivers over to use the new methods and the old ones will be
> going away in the future.  It would be great if we can avoid adding
> more code that uses those interfaces.

Can you point me to a driver that has been switched to use the new methods
already? Is there some other form of documentation?
