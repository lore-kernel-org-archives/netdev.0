From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fix IBM EMAC driver after rename.
Date: Thu, 18 Aug 2011 21:09:58 -0700
Message-ID: <1313726998.11178.10.camel@Joe-Laptop>
References: <20110818061354.GD19739@ozlabs.org>
	 <20110817.234947.611559275017926008.davem@davemloft.net>
	 <20110819012558.GF19739@ozlabs.org>
	 <20110818.204400.1898706003071593302.davem@davemloft.net>
	 <20110819035730.GI19739@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Tony Breeds <tony@bakeyournoodle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wondertoys-mx.wondertoys.net ([206.117.179.246]:38545 "EHLO
	labridge.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750703Ab1HSEKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 00:10:01 -0400
In-Reply-To: <20110819035730.GI19739@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 13:57 +1000, Tony Breeds wrote:
> On Thu, Aug 18, 2011 at 08:44:00PM -0700, David Miller wrote:
> > Don't do this :-(  When you reply to me as your new version of the patch
> > it craps up the commit message.
> > Always make a fresh, new, patch posting with a clean full commit message
> > without any non-essential material included.
> > I'm not applying this, because I'm pretty sick and tired of having to
> > edit up people's patch postings when they do stuff like this.
> Sorry I thought git am coped with this.

It can if you move the quoted stuff below the
---
separator, though I don't know what patchworks
does with threaded [PATCH V2] content.  I do
think it's useful when the corrected patch
is appropriately threaded.

The corrected patch email could look like:

Subject: [PATCH V2] module: description

typical multi-line patch description...

Signed-off-by: etc

---

> On some date, somebody wrote:
> quoted stuff

Description of delta between patch 1 and patch 2.

actual patch...


