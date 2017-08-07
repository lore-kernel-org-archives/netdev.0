From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] sctp: remove typedefs from structures
 part 5
Date: Sun, 06 Aug 2017 21:33:56 -0700 (PDT)
Message-ID: <20170806.213356.1004665749442304915.davem@davemloft.net>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50534 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdHGEd6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:33:58 -0400
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  5 Aug 2017 19:59:50 +0800

> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. This patchset is the
> part 5 to remove all typedefs in include/net/sctp/constants.h.
> 
> Just as the part 1-4, No any code's logic would be changed in these patches,
> only cleaning up.

Series applied, thank you.
