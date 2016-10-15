From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Fix compiler warnings
Date: Sat, 15 Oct 2016 17:48:50 -0400 (EDT)
Message-ID: <20161015.174850.1523283727470633263.davem@davemloft.net>
References: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chris.hyser@oracle.com,
        linux-kernel@vger.kernel.org
To: tushar.n.dave@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcJOVs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:48:57 -0400
In-Reply-To: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>
Date: Fri, 14 Oct 2016 17:06:04 -0700

> Recently, ATU (iommu) changes are submitted to linux-sparc that
> enables 64bit DMA on SPARC. However, this change also makes
> 'incompatible pointer type' compiler warnings inevitable on sunqe
> and sunbmac driver.
> 
> The two patches in series fix compiler warnings.

Only the sparc tree has this build problem, so these patches
really ought to be submitted for and applied there.

Thanks.
