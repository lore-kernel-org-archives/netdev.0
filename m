From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net caif: insert missing spaces in pr_* messages and
 unbreak multi-line strings
Date: Fri, 28 Oct 2016 13:47:47 -0400 (EDT)
Message-ID: <20161028.134747.1907524803559536162.davem@davemloft.net>
References: <20161025111842.8110-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36726 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756237AbcJ1Rrs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 13:47:48 -0400
In-Reply-To: <20161025111842.8110-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue, 25 Oct 2016 12:18:42 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Some of the pr_* messages are missing spaces, so insert these and also
> unbreak multi-line literal strings in pr_* messages
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
