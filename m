From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 0/4] tc: pedit fixes
Date: Wed, 2 Mar 2016 20:23:44 +0100
Message-ID: <20160302192344.GB26393@orbyte.nwl.cc>
References: <20160302095414.45a928df@xeon-e3>
 <1456944343-19058-1-git-send-email-phil@nwl.cc>
 <20160302110533.628ecfd2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58802 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbcCBTXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 14:23:46 -0500
Content-Disposition: inline
In-Reply-To: <20160302110533.628ecfd2@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2016 at 11:05:33AM -0800, Stephen Hemminger wrote:
> On Wed,  2 Mar 2016 19:45:39 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > While implementing an implementation example for a pedit man page, I
> > noticed several issues with the current code. The following patch
> > series addreses them.
> 
> Jamal wrote pedit, does he have any comments on this?

I didn't consult him in private, but appreciate his review of course.
