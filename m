From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add LINUX_MIB_PFMEMALLOCDROP counter
Date: Thu, 02 Feb 2017 23:34:36 -0500 (EST)
Message-ID: <20170202.233436.6454657700863317.davem@davemloft.net>
References: <1486010879.13103.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbacik@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdBCEok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:44:40 -0500
In-Reply-To: <1486010879.13103.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Feb 2017 20:47:59 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Debugging issues caused by pfmemalloc is often tedious.
> 
> Add a new SNMP counter to more easily diagnose these problems.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Josef Bacik <jbacik@fb.com>

Applied.
