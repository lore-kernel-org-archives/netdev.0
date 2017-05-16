From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] nfp: LSO, checksum and XDP datapath
 updates
Date: Tue, 16 May 2017 12:59:24 -0400 (EDT)
Message-ID: <20170516.125924.2267416702240466691.davem@davemloft.net>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51012 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751815AbdEPQ70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:59:26 -0400
In-Reply-To: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 15 May 2017 17:55:14 -0700

> This series introduces a number of refinements to standard features
> like LSO and checksum offload.  Three major features are support for
> CHECKSUM_COMPLETE, refinement of TSO handling and another small speed
> up for XDP TX.  This series also switches from depending on some 
> app FW<>driver ABI versions to heavier use of capabilities.

Series applied, thanks Jakub.
