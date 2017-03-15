From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] MAINTAINERS: remove MACVLAN and VLAN entries
Date: Wed, 15 Mar 2017 15:20:52 -0700 (PDT)
Message-ID: <20170315.152052.2231174015160489194.davem@davemloft.net>
References: <1489599586-31322-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753903AbdCOW3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:29:48 -0400
In-Reply-To: <1489599586-31322-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 15 Mar 2017 18:39:46 +0100

> macvlan.c file seems to be both in VLAN and MACVLAN DRIVER, so remove
> the MACVLAN DRIVER since this is redundant.
> 
> I propose with this patch to remove the VLAN (802.1Q) entry so this just
> falls into the NETWORKING [GENERAL].
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
