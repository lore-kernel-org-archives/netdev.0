From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] vhost-net fix for 2.6.34-rc4
Date: Wed, 14 Apr 2010 22:53:50 -0700 (PDT)
Message-ID: <20100414.225350.106746933.davem@davemloft.net>
References: <20100414141733.GA5370@redhat.com>
	<20100414.155715.210946931.davem@davemloft.net>
	<20100415040557.GA12108@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32946
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754837Ab0DOFxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 01:53:46 -0400
In-Reply-To: <20100415040557.GA12108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 15 Apr 2010 07:05:57 +0300

> On Wed, Apr 14, 2010 at 03:57:15PM -0700, David Miller wrote:
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Wed, 14 Apr 2010 17:17:33 +0300
>> 
>> > Christoph Hellwig (1):
>> >       vhost: fix sparse warnings
>> 
>> Do the sparse warnings show actual real bugs, or are we just
>> adding annotations to make the tool happy?
>> 
>> Unless the bugs being fixed are earth shattering, this belongs
>> in net-next-2.6 not net-2.6
> 
> No, these are just annotations to make the tool happy.
> Pls queue for net-next-2.6. Thanks!

Done, thanks Michael.
