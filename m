From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net: hns: Add missing \n to end of dev_err
 messages, tidy up text
Date: Thu, 06 Oct 2016 20:44:31 -0400 (EDT)
Message-ID: <20161006.204431.639714542977465440.davem@davemloft.net>
References: <20161004125701.13032-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        lipeng321@huawei.com, lisheng011@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcJGAof (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:44:35 -0400
In-Reply-To: <20161004125701.13032-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue,  4 Oct 2016 13:57:01 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trival fix, dev_err messages are missing a \n, so add it. Also
> fix grammer, spelling mistake and add white spaces to various
> error messages.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
