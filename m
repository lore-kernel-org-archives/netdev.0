From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCH net-next 0/8] xen-netback/core: packet
 hashing
Date: Mon, 26 Oct 2015 05:09:49 -0700 (PDT)
Message-ID: <20151026.050949.410612592925822264.davem@davemloft.net>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
	<20151024.045502.1977782979064243034.davem@davemloft.net>
	<562E02BA.5050301@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.durrant@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563AbbJZLxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 07:53:12 -0400
In-Reply-To: <562E02BA.5050301@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Mon, 26 Oct 2015 10:38:50 +0000

> On 24/10/15 12:55, David Miller wrote:
>> From: Paul Durrant <paul.durrant@citrix.com>
>> Date: Wed, 21 Oct 2015 11:36:17 +0100
>> 
>>> This series adds xen-netback support for hash negotiation with a frontend
>>> driver, and an implementation of toeplitz hashing as the initial negotiable
>>> algorithm.
>> 
>> Ping, I want to see some review from some other xen networking folks.
> 
> There's been some review of the front/back protocol (on a different
> thread) and some significant changes have been suggested.

Ok, I'll mark this series as "changes requested" then, thanks.
