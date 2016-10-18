From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: vlan: Use sizeof instead of literal number
Date: Tue, 18 Oct 2016 14:23:38 -0400 (EDT)
Message-ID: <20161018.142338.2215062328164690307.davem@davemloft.net>
References: <1476751442-12112-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45110 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933313AbcJRSXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:23:40 -0400
In-Reply-To: <1476751442-12112-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue, 18 Oct 2016 08:44:02 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Use sizeof variable instead of literal number to enhance the readability.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
