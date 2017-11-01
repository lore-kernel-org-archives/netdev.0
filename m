From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net-next): ipsec-next 2017-10-30
Date: Wed, 01 Nov 2017 12:17:00 +0900 (KST)
Message-ID: <20171101.121700.1242179398378385966.davem@davemloft.net>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754167AbdKADRD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:17:03 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 30 Oct 2017 09:39:27 +0100

> 1) Change some variables that can't be negative
>    from int to unsigned int. From Alexey Dobriyan.
> 
> 2) Remove a redundant header initialization in esp6.
>    From Colin Ian King.
> 
> 3) Some BUG to BUG_ON conversions.
>    From Gustavo A. R. Silva.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
