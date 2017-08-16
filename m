From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net repost] nfp: do not update MTU from BH in flower app
Date: Tue, 15 Aug 2017 21:03:58 -0700 (PDT)
Message-ID: <20170815.210358.1704629747295212922.davem@davemloft.net>
References: <20170811.145107.1539668262080149471.davem@davemloft.net>
        <20170815061347.GA14861@vergenet.net>
        <20170815.175240.1812725528326133547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdHPEEC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 00:04:02 -0400
In-Reply-To: <20170815.175240.1812725528326133547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 15 Aug 2017 17:52:40 -0700 (PDT)

> From: Simon Horman <simon.horman@netronome.com>
> Date: Tue, 15 Aug 2017 08:13:48 +0200
> 
>> Could you pull net into net-next? I'd like to send up a follow-up
>> for net-next to allow processing of the MTU.
> 
> Once Linus takes the pull request I just sent to him, I will
> do this.

And this is now done.
