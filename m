From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Add support for ndo_get_vf_config
Date: Sun, 04 Sep 2016 11:46:20 -0700 (PDT)
Message-ID: <20160904.114620.1885409381455953066.davem@davemloft.net>
References: <1472823833-6256-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754143AbcIDSqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 14:46:21 -0400
In-Reply-To: <1472823833-6256-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri,  2 Sep 2016 19:13:53 +0530

> Adds support for ndo_get_vf_config, also fill the default mac address
> that will be provided to the VF by firmware, in case user doesn't
> provide one. So user can get the default MAC address address also
> through ndo_get_vf_config.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
