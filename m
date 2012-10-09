From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] VXLAN bases source UDP port based on flow to help
 the receiver to be able to load balance based on outer header flow.
Date: Tue, 09 Oct 2012 14:14:57 -0400 (EDT)
Message-ID: <20121009.141457.2057591797207217303.davem@davemloft.net>
References: <20121009175637.048993312@vyatta.com>
	<20121009175714.682992341@vyatta.com>
	<20121009110754.57f229da@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822Ab2JISO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 14:14:58 -0400
In-Reply-To: <20121009110754.57f229da@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 9 Oct 2012 11:07:54 -0700

> Commit message messed up by quilt on this one, do you want to fix
> or should I resubmit?

I can take care of it.

 
