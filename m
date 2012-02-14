From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Fix kcalloc parameters swapped
Date: Tue, 14 Feb 2012 14:42:07 -0500 (EST)
Message-ID: <20120214.144207.182139685565921136.davem@davemloft.net>
References: <1329200354.3806.1.camel@phoenix>
	<18099.1329235408@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: axel.lin@gmail.com, linux-kernel@vger.kernel.org, zohar@us.ibm.com,
	thomas@m3y3r.de, anton@samba.org, netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757123Ab2BNTnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 14:43:20 -0500
In-Reply-To: <18099.1329235408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Tue, 14 Feb 2012 16:03:28 +0000

> Axel Lin <axel.lin@gmail.com> wrote:
> 
>> The first parameter should be "number of elements" and the second parameter
>> should be "element size".
>> 
>> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> 
> Not that it matters, I think, but let's be consistent...
> 
> Acked-by: David Howells <dhowells@redhat.com>

Applied.
