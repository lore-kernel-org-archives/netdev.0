From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: remove unused compl
 queue mapping
Date: Tue, 25 Apr 2017 11:55:14 -0400 (EDT)
Message-ID: <20170425.115514.1448173522233772597.davem@davemloft.net>
References: <1493067246-3247-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w-kwok2@ti.com, m-karicheri2@ti.com,
        linux-kernel@vger.kernel.org, grygorii.strashko@ti.com
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41116 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1950268AbdDYPzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:55:16 -0400
In-Reply-To: <1493067246-3247-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Mon, 24 Apr 2017 23:54:06 +0300

> This code is unused and probably was unintentionally left while
> moving completion queue mapping in submit function.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Applied.
