From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.2.x] net: reintroduce missing
 rcu_assign_pointer() calls
Date: Sun, 22 Jan 2012 14:17:04 -0500 (EST)
Message-ID: <20120122.141704.1917413460937023245.davem@davemloft.net>
References: <1395792.PECVbbCrna@asus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: bvanassche@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab2AVTRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2012 14:17:10 -0500
In-Reply-To: <1395792.PECVbbCrna@asus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You should not do this, I take care of all networking stable
patch submissions at a time of my own choosing.
