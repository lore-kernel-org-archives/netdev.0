From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: display the descriptors if DES0 = 0
Date: Thu, 20 Oct 2016 11:27:49 -0400 (EDT)
Message-ID: <20161020.112749.1578674762749719276.davem@davemloft.net>
References: <1476950488-24923-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964840AbcJTP1y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:27:54 -0400
In-Reply-To: <1476950488-24923-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Thu, 20 Oct 2016 10:01:28 +0200

> It makes sense to display the descriptors even if 
> DES0 is zero. This helps for example in case of it
> is needed to dump rx write-back descriptors to get
> timestamp status.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thank you.
