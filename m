From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Wed, 25 Jan 2017 14:03:33 -0500 (EST)
Message-ID: <20170125.140333.788366320476056385.davem@davemloft.net>
References: <20170125.122205.9460825196595773.davem@davemloft.net>
        <20170125175458.GF23545@1wt.eu>
        <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, eric.dumazet@gmail.com, netdev@vger.kernel.org,
        edumazet@google.com, ycheng@google.com, weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbdAYTDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:03:35 -0500
In-Reply-To: <CAC15z3hG36VcanxLXtvxP-ta=Srom8P6E5Rds+jGjJ8vLj7TeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Wed, 25 Jan 2017 10:54:50 -0800

>> Yes sorry David, for me it's OK. If Wei runs his whole series of tests
>> on it again, it should be perfect.
> 
> I just ran all the TFO related tests with Willy's patch on top of this
> patch series.
> And everything passes.

Great, I'll apply everything, thanks.
