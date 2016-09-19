From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net: r6040: add in missing white space in error
 message text
Date: Sun, 18 Sep 2016 22:22:41 -0400 (EDT)
Message-ID: <20160918.222241.2023931565916978660.davem@davemloft.net>
References: <20160916094338.23698-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbcISCWo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:22:44 -0400
In-Reply-To: <20160916094338.23698-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Fri, 16 Sep 2016 10:43:38 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> A couple of dev_err messages span two lines and the literal
> string is missing a white space between words. Add the white
> space and join the two lines into one.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
