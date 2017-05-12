From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] Two generic xdp related follow-ups
Date: Thu, 11 May 2017 21:31:19 -0400 (EDT)
Message-ID: <20170511.213119.1933854850284274886.davem@davemloft.net>
References: <cover.1494542162.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757391AbdELBbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:31:21 -0400
In-Reply-To: <cover.1494542162.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 12 May 2017 01:04:44 +0200

> Two follow-ups for the generic XDP API, would be great if
> both could still be considered, since the XDP API is not
> frozen yet. For details please see individual patches.
> 
> v1 -> v2:
>   - Implemented feedback from Jakub Kicinski (reusing
>     attribute on dump), thanks!
>   - Rest as is.

Series applied, thanks for working on this.
