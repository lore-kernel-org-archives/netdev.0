From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-04-28
Date: Fri, 28 Apr 2017 15:44:00 -0400 (EDT)
Message-ID: <20170428.154400.2155871099187953476.davem@davemloft.net>
References: <1493368958-29609-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753774AbdD1ToB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:44:01 -0400
In-Reply-To: <1493368958-29609-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Apr 2017 10:42:37 +0200

> Just one patch to fix a misplaced spin_unlock_bh in an error path.
> 
> Please pull or let me know if there are problems.


Pulled, thank you.
