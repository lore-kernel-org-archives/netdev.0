From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 10:56:27 -0700
Message-ID: <1345830987.32359.4.camel@joe2Laptop>
References: <1345777345.16471.18.camel@joe2Laptop>
	 <20120824063240.GB2212@netboy.at.omicron.at>
	 <1345800154.16471.20.camel@joe2Laptop>
	 <20120824.111238.1400056420671100883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36684 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752012Ab2HXR43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 13:56:29 -0400
In-Reply-To: <20120824.111238.1400056420671100883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 11:12 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri, 24 Aug 2012 02:22:34 -0700
> > On Fri, 2012-08-24 at 08:32 +0200, Richard Cochran wrote:
> >> On Thu, Aug 23, 2012 at 08:02:25PM -0700, Joe Perches wrote:
> >> > Improving code clarity and consistency isn't churn.
> >> This patch series moves code around for no good reason. That is, by
> >> definition, churn.
> > 
> > For your definition of good.
> 
> I think the people doing all of the actual development and
> maintainence of the code get to decide how to define good.  And in
> this case that's basically the Intel NIC development team, not you.

Just for clarity, you do mean Richard's view and not mine.
I agree with these proposed changes.

> Moving functions around is a very valuable and useful cleanup quite
> often.
> 
> So you can count me in on their definition of "good" as well.
