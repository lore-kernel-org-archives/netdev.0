From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: Remove unused len field
Date: Sun, 23 Oct 2016 17:45:25 -0400 (EDT)
Message-ID: <20161023.174525.1420508806882731468.davem@davemloft.net>
References: <fb52764c89fa8c11ec832bd4ddf7595b6a673ce1.1477058913.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, roopa@cumulusnetworks.com,
        netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756740AbcJWVp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 17:45:26 -0400
In-Reply-To: <fb52764c89fa8c11ec832bd4ddf7595b6a673ce1.1477058913.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 21 Oct 2016 16:10:22 +0200

> The field is initialized by ILA and MPLS but never used. Remove it.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
