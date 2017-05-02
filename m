From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] net: thunderx: Adds XDP support
Date: Tue, 02 May 2017 15:47:44 -0400 (EDT)
Message-ID: <20170502.154744.1762061314370744901.davem@davemloft.net>
References: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdEBTrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:47:47 -0400
In-Reply-To: <1493730418-24606-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sunil.kovvuri@gmail.com
Date: Tue,  2 May 2017 18:36:49 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch series adds support for XDP to ThunderX NIC driver
> which is used on CN88xx, CN81xx and CN83xx platforms. 
> 
> Patches 1-4 are performance improvement and cleanup patches
> which are done keeping XDP performance bottlenecks in view.
> Rest of the patches adds actual XDP support.

Series applied, thanks for doing this work.

Do you have any performance numbers?
