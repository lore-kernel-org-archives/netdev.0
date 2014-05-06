From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 11:09:19 -0700
Message-ID: <20140506180919.GG20776@cloud>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
 <536917EB.60605@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53964 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaEFSJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:09:25 -0400
Content-Disposition: inline
In-Reply-To: <536917EB.60605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 10:12:11AM -0700, Rick Jones wrote:
> On 05/06/2014 09:41 AM, josh@joshtriplett.org wrote:
> >On Tue, May 06, 2014 at 11:59:41AM -0400, David Miller wrote:
> >>Making 2MB RAM machines today makes no sense at all.
> >>
> >>The lowest end dirt cheap smartphone, something which fits on
> >>someone's pocket, has gigabytes of ram.
> >
> >The lowest-end smartphone isn't anywhere close to "dirt cheap", and
> >hardly counts as "embedded" at all anymore.  Smartphones cost $100+;
> >we're talking about systems in the low tens of dollars or less.  These
> >systems will have no graphics, no peripherals, and only one or two
> >specific functions.  The entirety of their functionality will likely
> >consist of a single userspace program; they might not even have a PID 2.
> >*That's* the kind of "embedded" we're talking about, not the
> >supercomputers we carry around in our pockets.
> 
> Would this be some sort of "Internet of Things" system?

That's one of many buzzwords being used for this kind of system, sure.
The "Internet of" part makes networking particularly important.

- Josh Triplett
