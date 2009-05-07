From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Wed, 6 May 2009 17:42:46 -0700
Message-ID: <4A022E86.4040101@netxen.com>
References: <4A022666.4060906@netxen.com>	<20090506.172801.102105067.davem@davemloft.net>	<4A022BFD.40806@netxen.com> <20090506.174009.151445285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:15289 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754357AbZEGAmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 20:42:46 -0400
In-Reply-To: <20090506.174009.151445285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> I personally think 4 would be more appropriate.
> 
> That's what I end up using in 4-port 1G NIU configurations.

Ok, I will leave it at 4 for now, will revisit this when
sriov stuff gets submitted.

Thanks,
Dhananjay
