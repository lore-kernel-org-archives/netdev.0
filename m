From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: dwc-qos: Add suspend / resume support
Date: Thu, 28 Sep 2017 10:19:21 -0700 (PDT)
Message-ID: <20170928.101921.1422558523458858739.davem@davemloft.net>
References: <1506422626-26058-1-git-send-email-ed.blake@sondrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: ed.blake@sondrel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751339AbdI1RTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:19:22 -0400
In-Reply-To: <1506422626-26058-1-git-send-email-ed.blake@sondrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Blake <ed.blake@sondrel.com>
Date: Tue, 26 Sep 2017 11:43:46 +0100

> Add hook to stmmac_pltfr_pm_ops for suspend / resume handling.
> 
> Signed-off-by: Ed Blake <ed.blake@sondrel.com>

Applied.
