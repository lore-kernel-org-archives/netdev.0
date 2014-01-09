From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 05/15] i40e: add a comment on barrier and fix panic
 on reset
Date: Thu, 9 Jan 2014 21:23:10 +0000
Message-ID: <1389302590.2025.55.camel@bwh-desktop.uk.level5networks.com>
References: <1389271944-26227-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52CEB538.50505@cogentembedded.com> <20140109091735.00002cf0@unknown>
	 <20140109.151224.1539252523028219271.davem@davemloft.net>
	 <1389302517.2025.54.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gregory.v.rose@intel.com>, <sergei.shtylyov@cogentembedded.com>,
	<jeffrey.t.kirsher@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>,
	<mitch.a.williams@intel.com>, <jesse.brandeburg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21469 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516AbaAIVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 16:23:14 -0500
In-Reply-To: <1389302517.2025.54.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 21:21 +0000, Ben Hutchings wrote:
> On Thu, 2014-01-09 at 15:12 -0500, David Miller wrote:
> > From: Greg Rose <gregory.v.rose@intel.com>
> > Date: Thu, 9 Jan 2014 09:17:35 -0800
> > 
> > > Yes, it's apparent that two different internal patches were compressed
> > > together.  If its unacceptable to do this then I'll speak to Jeff about
> > > splitting them.
> > 
> > I won't reject the entire pull request on account of this, but please
> > don't do this in the future.
> 
> I don't understand this.  You don't want to see patches that are known
> to introduce regressions, and you expect people to squash together known
> buggy patches with their subsequent fix-ups before submitting.
[...]

Hmm, looking at this again, I suppose it is just this particular
combination of two unrelated changes you're objecting to?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
