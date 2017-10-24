From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] ipv6: addrconf: hash improvements and
 cleanups
Date: Tue, 24 Oct 2017 17:54:58 +0900 (KST)
Message-ID: <20171024.175458.677271880727624289.davem@davemloft.net>
References: <20171023231751.29530-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932148AbdJXIzB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:55:01 -0400
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 23 Oct 2017 16:17:44 -0700

> Remove unecessary BH blocking, and bring IPv6 addrconf to modern world,
> with per netns hash perturbation and decent hash size.

Series applied.
