From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Thu, 23 Feb 2017 10:45:08 -0500 (EST)
Message-ID: <20170223.104508.1483994534223572192.davem@davemloft.net>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdBWPpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:45:10 -0500
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 22 Feb 2017 11:38:49 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> RFCv2:
> 
> I have received a few requests for status and rebased code of this
> feature. We have been running this code internally, discovering and
> fixing various bugs. With net-next closed, now seems like a good time
> to share an updated patchset with fixes. The rebase from RFCv1/v4.2
> was mostly straightforward: mainly iov_iter changes. Full changelog:

I've been over this series once or twice and generally speaking it looks
fine to me.
