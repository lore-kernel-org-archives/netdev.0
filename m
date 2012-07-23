From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Mon, 23 Jul 2012 14:44:21 -0700 (PDT)
Message-ID: <20120723.144421.1741050474189216927.davem@davemloft.net>
References: <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
	<20120723.143436.2124127996154789223.davem@davemloft.net>
	<CAJZOPZKp4su8sOV1Cpm5CG2DYY2xVKUjrSFge5qcYn2pnkC-YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klebers@linux.vnet.ibm.com, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	yevgenyp@mellanox.co.il, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, shlomop@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab2GWVoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:44:22 -0400
In-Reply-To: <CAJZOPZKp4su8sOV1Cpm5CG2DYY2xVKUjrSFge5qcYn2pnkC-YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 24 Jul 2012 00:42:08 +0300

> On Tue, Jul 24, 2012 at 12:34 AM, David Miller <davem@davemloft.net> wrote:
> 
>> Can we please move forward, if he implemented the feature properly
>> and he tested it successfully, unless you can find a logic or
>> stylistic flaw in his patch please ACK it.
>>
>> You can't hold his changes back while you work out how _YOU_ can
>> test it to your liking.
> 
> Hi Dave,
> 
> We're trying to act in  R/R (Responsive and Responsible) manner -
> namely Shlomo did code review of the patches and we want to further
> evaluate them by testing, I think its fully legitimate to test a patch
> before ACK-ing.  Doing these types of tests isn't around my personal
> typical daily menu and I'm asking for some directives from the author
> on how to issue that testing, I don't see what wrong here. We're
> planning anyway to go deeper around this area and enhance the PCI
> hotplug /error handling related code in the driver, so there's an
> initial learing curve here, makes sense? we can move the Q&A for the
> testing to be off-list if you prefer it to go that way.

But ACK his patch, because you have not found any problems with it.

This is taking days, and you're stalling further progress.

I never let patches rot in patchwork more than a few days, as this
patch has already.

Either ACK or provide a legitimate reason to reject it now.
