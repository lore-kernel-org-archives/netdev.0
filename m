From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/10] qed: DCBx and Attentions series
Date: Tue, 30 May 2017 12:10:27 -0400 (EDT)
Message-ID: <20170530.121027.664149668876855145.davem@davemloft.net>
References: <1496040794-6163-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdE3QK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:10:29 -0400
In-Reply-To: <1496040794-6163-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Mon, 29 May 2017 09:53:04 +0300

> The series contains 2 major components [& some odd bits]:
>  - The first 3 patches are DCBx-related, containg missing bits in the
>    implementation, correcting existing API and removing code no longer
>    necessary.
>  - Most of the remaining patches are interrupt/hw-attention related,
>    adding some differeneces relating to QL41xxx and QL45xxx differences.
>    While at it, they also remove a large chunk of unnecessary structure
>    definitions.
> 
> The series also contain a patch [#10] that was accidently missing
> from a previous series.

Series applied, thanks.
