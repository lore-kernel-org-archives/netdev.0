From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: remove duplicate routing header type
 check
Date: Mon, 11 Sep 2017 14:34:25 -0700 (PDT)
Message-ID: <20170911.143425.1328061758576481750.davem@davemloft.net>
References: <20170910132201.15576-1-dav.lebrun@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dav.lebrun@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdIKVeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:34:25 -0400
In-Reply-To: <20170910132201.15576-1-dav.lebrun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <dav.lebrun@gmail.com>
Date: Sun, 10 Sep 2017 14:22:01 +0100

> From: David Lebrun <dlebrun@google.com>
> 
> As seg6_validate_srh() already checks that the Routing Header type is
> correct, it is not necessary to do it again in get_srh().
> 
> Fixes: 5829d70b ("ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC 8200")
> Signed-off-by: David Lebrun <dlebrun@google.com>

Applied thanks.
