From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 11:12:38 -0400 (EDT)
Message-ID: <20120824.111238.1400056420671100883.davem@davemloft.net>
References: <1345777345.16471.18.camel@joe2Laptop>
	<20120824063240.GB2212@netboy.at.omicron.at>
	<1345800154.16471.20.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab2HXPMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 11:12:41 -0400
In-Reply-To: <1345800154.16471.20.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 24 Aug 2012 02:22:34 -0700

> On Fri, 2012-08-24 at 08:32 +0200, Richard Cochran wrote:
>> On Thu, Aug 23, 2012 at 08:02:25PM -0700, Joe Perches wrote:
>> 
>> > Improving code clarity and consistency isn't churn.
>> 
>> This patch series moves code around for no good reason. That is, by
>> definition, churn.
> 
> For your definition of good.

I think the people doing all of the actual development and
maintainence of the code get to decide how to define good.  And in
this case that's basically the Intel NIC development team, not you.

Moving functions around is a very valuable and useful cleanup quite
often.

So you can count me in on their definition of "good" as well.
