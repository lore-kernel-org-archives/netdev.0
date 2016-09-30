From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: bpf: zero extend 4 byte context loads
Date: Fri, 30 Sep 2016 02:10:41 -0400 (EDT)
Message-ID: <20160930.021041.1404033191532996955.davem@davemloft.net>
References: <1475102857-23672-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935528AbcI3GKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 02:10:44 -0400
In-Reply-To: <1475102857-23672-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 28 Sep 2016 23:47:37 +0100

> Set upper 32 bits of destination register to zeros after
> load from the context structure.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thanks.
