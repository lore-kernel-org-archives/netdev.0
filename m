From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/1] tools: hv: ignore a NIC if it has been
 configured
Date: Sun, 16 Jul 2017 16:36:48 -0700 (PDT)
Message-ID: <20170716.163648.2126356115393718878.davem@davemloft.net>
References: <1500054440-11228-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, haiyangz@microsoft.com,
        sthemmin@microsoft.com
To: sixiao@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdGPXgt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 19:36:49 -0400
In-Reply-To: <1500054440-11228-1-git-send-email-sixiao@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixiao@microsoft.com>
Date: Fri, 14 Jul 2017 10:47:20 -0700

> Let bondvf.sh ignore this NIC if it has been configured, to prevent
> user configuration from being overwritten unexpectly.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>

Applied.
