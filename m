From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2012-01-05
Date: Thu, 5 Jan 2012 12:49:07 -0500
Message-ID: <20120105174906.GD10666@tuxdriver.com>
References: <20120105160938.GC10666@tuxdriver.com>
 <20120105.123039.977245333906219511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48291 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335Ab2AESA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:00:57 -0500
Content-Disposition: inline
In-Reply-To: <20120105.123039.977245333906219511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 05, 2012 at 12:30:39PM -0500, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 5 Jan 2012 11:09:38 -0500
> 
> > Here is the last wireless "feature" pull request intended for 3.3.
> > Mostly minutia, but highlights include an NFC spec update and some
> > relicensing of regulatory code under the ISC license.
> > 
> > After consulation with Kalle, I have reverted the ath6kl USB bits that
> > were causing build problems.
> > 
> > Please let me know if there are problems!
> > 
> > John
> > 
> > P.S. Sorry about the "ssh://" URL -- git.kernel.org seems a bit slow
> > about syncing today...
> 
> That ssh URL would only work for you, since I don't have permission to get
> at your trees even just to pull.

Hmmm...really?  I'm pretty sure I pulled other trees that way.

> I pulled from the equivalent git:// URL, the top commit was the ath6kl
> USB revert.

Sure, that's fine.

Thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
