From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Wed, 05 Jul 2006 20:03:25 -0700 (PDT)
Message-ID: <20060705.200325.74731166.davem@davemloft.net>
References: <adar7119kix.fsf@cisco.com>
	<20060705.112703.71101840.davem@davemloft.net>
	<adaac7naj80.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23772
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965088AbWGFDDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 23:03:00 -0400
To: rdreier@cisco.com
In-Reply-To: <adaac7naj80.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Wed, 05 Jul 2006 13:29:35 -0700

> The way forward seems to be to merge basic iWARP support that lives in
> drivers/infiniband, and then you can accept or reject things for
> better integration, like notifiers for routing changes.

<sarcasm>
Let's merge in drivers before the necessary infrastructure.
</sarcasm>

No, I think that's not the way forward.  You build the foundation
before the house, if the foundation cannot be built then you are
wasting your time with the house idea.

