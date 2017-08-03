From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] sctp: remove typedefs from structures
 part 4
Date: Thu, 03 Aug 2017 09:46:05 -0700 (PDT)
Message-ID: <20170803.094605.2134265917430921792.davem@davemloft.net>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdHCQqH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:46:07 -0400
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  3 Aug 2017 15:42:08 +0800

> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. This patchset is the
> part 4 to remove it for another 14 basic structures from linux/sctp.h.
> After this patchset, all typedefs are cleaned in linux/sctp.h.
> 
> Just as the part 1-3, No any code's logic would be changed in these patches,
> only cleaning up.

Series applied, thanks.
