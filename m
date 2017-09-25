From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4] net: nfc: llcp_core: use setup_timer() helper.
Date: Mon, 25 Sep 2017 13:19:50 -0700 (PDT)
Message-ID: <20170925.131950.225487585379842278.davem@davemloft.net>
References: <1506324605-10160-1-git-send-email-allen.lkml@gmail.com>
        <1506324605-10160-4-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sameo@linux.intel.com
To: allen.lkml@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58790 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966113AbdIYUTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 16:19:51 -0400
In-Reply-To: <1506324605-10160-4-git-send-email-allen.lkml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allen Pais <allen.lkml@gmail.com>
Date: Mon, 25 Sep 2017 13:00:05 +0530

> Use setup_timer function instead of initializing timer with the
>    function and data fields.
> 
> Signed-off-by: Allen Pais <allen.lkml@gmail.com>
> ---
> v2: rebased to latest net-next.

Applied.
