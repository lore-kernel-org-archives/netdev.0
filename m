From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/9] liquidio VF operations
Date: Wed, 30 Nov 2016 11:03:26 -0500 (EST)
Message-ID: <20161130.110326.2092497560156737235.davem@davemloft.net>
References: <1480380881-19255-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757133AbcK3QDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:03:41 -0500
In-Reply-To: <1480380881-19255-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Mon, 28 Nov 2016 16:54:32 -0800

> This patchseries adds support for VF device specific operations
> like mailbox, queues and register access. This V3 patchset also
> has changes based on comments form earlier versions:
> 
> 1) Removed extra 'void *' casting.
> 2) Fixed all cross compilations issues reported on S390 and Powerpc
>    architectures.
> 
> Please apply the patches in following order as these patches depend
> on each other.

Series applied, thanks.
