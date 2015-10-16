From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 01:08:26 -0700 (PDT)
Message-ID: <20151016.010826.1557577128395519123.davem@davemloft.net>
References: <cover.1444926905.git.jbenc@redhat.com>
	<87r3kv3hwv.fsf@stressinduktion.org>
	<20151016094951.11146959@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbbJPHwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:52:18 -0400
In-Reply-To: <20151016094951.11146959@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 16 Oct 2015 09:49:51 +0200

> On Fri, 16 Oct 2015 00:07:12 +0200, Hannes Frederic Sowa wrote:
>> Do you plan to update rfc3549, too? :}
> 
> No.
> 
> While I think we need to have a detailed documentation on netlink,
> I believe it should reside in Documentation/ inside the kernel tree to
> be easily updated, not in an outside document collection with much more
> heavyweight processes around getting something updated.

I think his point is that you'll be making changes to an RFC specified
protocol.

But I think we need a better solution to this.
