From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] sctp: remove typedefs from structures
 part 3
Date: Mon, 24 Jul 2017 16:01:42 -0700 (PDT)
Message-ID: <20170724.160142.2083958119525898930.davem@davemloft.net>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754336AbdGXXBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:01:45 -0400
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 23 Jul 2017 09:34:25 +0800

> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. This patchset is the
> part 3 to remove it for another 11 basic structures from linux/sctp.h.
> 
> Just as the part 1 and 2, No any code's logic would be changed in these
> patches, only cleaning up.

Series applied, thanks.
