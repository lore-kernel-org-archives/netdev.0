From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT]: Networking
Date: Tue, 06 Jan 2009 05:27:58 +0100
Message-ID: <871vvhdpo1.fsf@basil.nowhere.org>
References: <20090105.183106.252630446.davem@davemloft.net>
	<alpine.LFD.2.00.0901051839330.3057@localhost.localdomain>
	<20090105.201530.195720489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41157 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbZAFE2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 23:28:00 -0500
In-Reply-To: <20090105.201530.195720489.davem@davemloft.net> (David Miller's message of "Mon, 05 Jan 2009 20:15:30 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> The default is extremely strict, which makes me check things out by
> hand.  That's good, but as I add the change by hand after verifying
> it's sanity I often make mistakes that result in things like the above
> missed delete, so if I could ask git to be non-strict it would help me
> out a lot.

Sorry for the me too, but I would really love to have such a feature
too.

-Andi


-- 
ak@linux.intel.com
