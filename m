From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Wed, 27 Jun 2012 22:22:05 -0700 (PDT)
Message-ID: <20120627.222205.980986053418491455.davem@davemloft.net>
References: <20120627.170830.811332455348620174.davem@davemloft.net>
	<1340860102.26242.203.camel@edumazet-glaptop>
	<1340860399.26242.206.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hans.schillstrom@ericsson.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab2F1FWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 01:22:06 -0400
In-Reply-To: <1340860399.26242.206.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jun 2012 07:13:19 +0200

> On Thu, 2012-06-28 at 07:08 +0200, Eric Dumazet wrote:
> 
>> The initial idea was to perform this only for SYN packets received on a
>> listener in SYNCOOKIE mode. I'll resend the patch when fully
>> implemented, instead of a forward patch.
>> 
> 
> s/forward/followup/
> 
> ;)

Ok :-)
