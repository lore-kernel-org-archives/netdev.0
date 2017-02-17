From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next (repost)] nfp: Use
 PCI_DEVICE_ID_NETRONOME_NFP* defines
Date: Fri, 17 Feb 2017 15:11:57 -0500 (EST)
Message-ID: <20170217.151157.1645991805695059549.davem@davemloft.net>
References: <1487318274-17216-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        dinan.gunawardena@netronome.com, oss-drivers@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932655AbdBQUW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 15:22:26 -0500
In-Reply-To: <1487318274-17216-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 17 Feb 2017 08:57:54 +0100

> Use PCI_DEVICE_ID_NETRONOME_NFP*, defined in linux/pci_ids.h,
> rather than replicating the same values in the NFP driver.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> ---
> * Reposted with subject and changelog adjusted to be less likely to be
>   flagged as spam

Applied, thanks.
