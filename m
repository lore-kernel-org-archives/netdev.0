From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: netprio_cgroup: make net_prio_subsys
 static
Date: Thu, 08 Dec 2011 19:53:39 -0500 (EST)
Message-ID: <20111208.195339.152346047030004418.davem@davemloft.net>
References: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
	<20111208114555.GA1246@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab1LIAy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:54:56 -0500
In-Reply-To: <20111208114555.GA1246@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 8 Dec 2011 06:45:55 -0500

> On Wed, Dec 07, 2011 at 09:17:17PM -0800, John Fastabend wrote:
>> net_prio_subsys can be made static this removes the sparse
>> warning it was throwing.
>> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
