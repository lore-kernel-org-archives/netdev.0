From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] korina: performance fixes and cleanup
Date: Mon, 18 Sep 2017 16:50:20 -0700 (PDT)
Message-ID: <20170918.165020.677623753477725447.davem@davemloft.net>
References: <20170917172353.32225-1-roman@advem.lv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leroi.lists@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbdIRXuV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:50:21 -0400
In-Reply-To: <20170917172353.32225-1-roman@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Yeryomin <leroi.lists@gmail.com>
Date: Sun, 17 Sep 2017 20:23:53 +0300

> Changes from v1:
> - use GRO instead of increasing ring size
> - use NAPI_POLL_WEIGHT instead of defining own NAPI_WEIGHT
> - optimize rx descriptor flags processing

Series applied, thank you.
