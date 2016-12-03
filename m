From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: stmmac: avoid Camelcase naming
Date: Sat, 03 Dec 2016 15:24:07 -0500 (EST)
Message-ID: <20161203.152407.847486502473264265.davem@davemloft.net>
References: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbcLCUeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 15:34:37 -0500
In-Reply-To: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Thu,  1 Dec 2016 16:19:40 +0100

> This patch simply rename regValue to value, like it was named in other
> mdio functions.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied.
