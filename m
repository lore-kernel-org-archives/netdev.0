From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-09-01
Date: Fri, 01 Sep 2017 09:54:48 -0700 (PDT)
Message-ID: <20170901.095448.1483052059481969830.davem@davemloft.net>
References: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIAQyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 12:54:49 -0400
In-Reply-To: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 1 Sep 2017 09:30:44 +0200

> This should be the last ipsec-next pull request for this
> release cycle:
> 
> 1) Support netdevice ESP trailer removal when decryption
>    is offloaded. From Yossi Kuperman.
> 
> 2) Fix overwritten return value of copy_sec_ctx().
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
