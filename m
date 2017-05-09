From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 09:30:03 -0400 (EDT)
Message-ID: <20170509.093003.1783910287153887824.davem@davemloft.net>
References: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
        <1494336215.7796.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pray3r.z@gmail.com, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50652 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752576AbdEINaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 09:30:04 -0400
In-Reply-To: <1494336215.7796.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 May 2017 06:23:35 -0700

> I will send a V2, putting the fix in inet_csk_clone_lock() so that DCCP
> is also fixed ;)

Thank you :)
