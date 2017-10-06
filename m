From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: remove unused code in ipv6_find_hdr()
Date: Thu, 05 Oct 2017 22:15:51 -0700 (PDT)
Message-ID: <20171005.221551.657368686354482984.davem@davemloft.net>
References: <1507226828-51366-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdJFFPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:15:54 -0400
In-Reply-To: <1507226828-51366-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Zhang <xiaolou4617@gmail.com>
Date: Fri,  6 Oct 2017 02:07:08 +0800

> Storing the left length of skb into 'len' actually has no effect 
> so we can remove it.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>

Applied.
