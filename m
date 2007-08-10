From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [NET] ethtool: Add LRO support
Date: Fri, 10 Aug 2007 05:32:28 -0400
Message-ID: <46BC30AC.7090109@garzik.org>
References: <20070809164117.9907.23351.stgit@localhost.localdomain>	<46BC2504.9010400@garzik.org> <20070810.022842.85409561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51121 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760115AbXHJJca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 05:32:30 -0400
In-Reply-To: <20070810.022842.85409561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 10 Aug 2007 04:42:44 -0400
> 
>> I'll code this up, along with the associated generic helpers 
>> (net/core/ethtool.c), if there are no objections.
> 
> No objections except I would give the driver private it's
> own set of flags.

Great minds think alike, I started leaning towards that as I coded up 
ETHTOOL_[GS]FLAGS...

	Jeff



