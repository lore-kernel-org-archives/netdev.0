From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] skb data accessors cleanup
Date: Fri, 16 Jun 2017 15:44:54 -0400 (EDT)
Message-ID: <20170616.154454.257581637376469956.davem@davemloft.net>
References: <20170616070747.3332-1-johannes@sipsolutions.net>
        <20170616.115013.1187787408957466917.davem@davemloft.net>
        <1497642203.10546.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
        julia.lawall@lip6.fr
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752444AbdFPTo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:44:56 -0400
In-Reply-To: <1497642203.10546.16.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 16 Jun 2017 12:43:23 -0700

> On Fri, 2017-06-16 at 11:50 -0400, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Fri, 16 Jun 2017 09:07:42 +0200
>> 
>> > Over night, Fengguang's bot told me that it compiled all of its many
>> > various configurations successfully, and I had done allyesconfig on
>> > x86_64 myself yesterday to iron out the things I missed.
>> > 
>> > So now I think I'm happy with it.
> 
> Nice work Johannes. thanks.
> 
> Next up: skb_push?
>  
>> Series applied, thanks!
> 
> David, it seems you applied the V2 version of
> this patchset.  When you
> apply revised patches,
> can you please reply to the V2 submission?
> 
> It's a bit confusing otherwise.

Sorry, that happens from time to time :-(
