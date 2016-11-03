From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove unused argument in checksum
 unnecessary conversion
Date: Thu, 03 Nov 2016 16:08:56 -0400 (EDT)
Message-ID: <20161103.160856.2134906471983673891.davem@davemloft.net>
References: <1478117651-24909-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754631AbcKCUI6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:08:58 -0400
In-Reply-To: <1478117651-24909-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed,  2 Nov 2016 16:14:11 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> The check argument is never used. This code has not changed since
> the original introduction in d96535a17dbb ("net: Infrastructure for
> checksum unnecessary conversions"). Remove the unused argument and
> update all callers.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
