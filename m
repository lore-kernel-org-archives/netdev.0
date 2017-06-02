From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next, 2/2] tools: hv: set hotplug for VF on Suse
Date: Fri, 02 Jun 2017 14:16:30 -0400 (EDT)
Message-ID: <20170602.141630.2138035412289438557.davem@davemloft.net>
References: <1496251707-14330-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, haiyangz@microsoft.com,
        sthemmin@microsoft.com
To: sixiao@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBSQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:16:32 -0400
In-Reply-To: <1496251707-14330-1-git-send-email-sixiao@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixiao@microsoft.com>
Date: Wed, 31 May 2017 10:28:27 -0700

> On HyperV, the VF interface can be offered by a host at any time.
> Mark the VF interface as hotplug, to make sure it will be brought up
> automatically when it is registered.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
