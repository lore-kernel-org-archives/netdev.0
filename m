From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 15:16:10 -0700
Message-ID: <468584AA.2030602@intel.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37517 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753591AbXF2WQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 18:16:15 -0400
In-Reply-To: <20070629150350.414553d4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 29 Jun 2007 14:39:20 -0700
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> That's why we want to introduce a second e1000 driver (named differently, pick 
>> any name) that contains the new code base, side-by-side into the kernel with the 
>> current e1000.
> 
> Sounds like a reasonable approach to me (it has plenty of precedent).  But
> I forget what all the other issues were, so ignore me.
> 
>> This new e1000 codebase goes miles and miles beyond what I posted in april/march 
>> and what is in -mm.
> 
> There are no e1000 changes in -mm (from you), I don't believe.  git-e1000
> has been in permadrop mode since 2.6.22-rc1-mm1 due to a huge number of git
> rejects/conflicts.
> 
> Is git://lost.foo-projects.org/~ahkok/git/netdev-2.6#mm the correct URL?

no, not yet, please remove that tree. I'll post a new one when ready.

Auke
