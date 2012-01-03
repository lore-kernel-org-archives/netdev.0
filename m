From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 03 Jan 2012 15:27:39 -0500 (EST)
Message-ID: <20120103.152739.1456113375065412910.davem@davemloft.net>
References: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20120103.150936.572765552893657192.davem@davemloft.net>
	<804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: bruce.w.allan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab2ACU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:27:43 -0500
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Date: Tue, 3 Jan 2012 20:16:44 +0000

> I was under the impression from recently accepted patches that the preferred
> method for log/error message strings was to keep them as a single string
> (rather than broken across multiple lines) for easy searching.  Is that not
> the case here?
> 
>>From ./Documentation/CodingStyle..."never break user-visible strings such as
> printk messages, because that breaks the ability to grep for them."
> 
> Do you still want this change?

Fair enough, I rescind my request and this patch is fine as-is.
