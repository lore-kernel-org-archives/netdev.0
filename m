From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] pf_packet updates
Date: Thu, 29 Aug 2013 12:53:15 -0400 (EDT)
Message-ID: <20130829.125315.1922344251280499471.davem@davemloft.net>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
	<20130829.013938.2144325735677512661.davem@davemloft.net>
	<1377771945.8277.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab3H2QxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 12:53:19 -0400
In-Reply-To: <1377771945.8277.26.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Aug 2013 03:25:45 -0700

> On Thu, 2013-08-29 at 01:39 -0400, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 28 Aug 2013 22:13:08 +0200
>> 
>> > Daniel Borkmann (3):
>> >   net: packet: add random fanout scheduler
>> >   net: packet: use reciprocal_divide in fanout_demux_hash
>> >   net: packet: document available fanout policies
>> 
>> Please add the missing reciprocal_divide.h include to the second
>> patch, as per Eric Dumazet's feedback, and resubmit this series.
> 
> (It was Cong Wang feedback ;) )

Sorry Eric, I am just too anxious to give you credit everywhere that I
can. :-)

Anyways, thanks for explaining Daniel, I've put these patches back into
the to-apply queue.

Thanks!
