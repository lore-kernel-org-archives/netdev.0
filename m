From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH] dql: make dql_init return void
Date: Wed, 18 Oct 2017 21:15:22 +0900
Message-ID: <20171018211522.7527ee9adacb0e7f6af8e7d2@gmail.com>
References: <20171018001652.23740-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, davem@davemloft.net, netdev@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:49103 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753816AbdJRMP0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 08:15:26 -0400
Received: by mail-pg0-f68.google.com with SMTP id v78so4133045pgb.5
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 05:15:26 -0700 (PDT)
In-Reply-To: <20171018001652.23740-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Oct 2017 17:16:52 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> dql_init always returned 0, and the only place that uses it
> in network core code didn't care about the return value anyway.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Acked-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
