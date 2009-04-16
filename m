From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 15:20:21 -0700 (PDT)
Message-ID: <20090416.152021.03754751.davem@davemloft.net>
References: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
	<49E7A0D2.60504@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, cl@linux.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753449AbZDPWU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:20:29 -0400
In-Reply-To: <49E7A0D2.60504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 16 Apr 2009 17:19:14 -0400

> I wonder how BSD and Solaris got away with it?  They both filter on
> multicast groups and source addresses.  This is not meant as
> rhetorical or provocative, just genuinely wondering.

Smaller user base.
