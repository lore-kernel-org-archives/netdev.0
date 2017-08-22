From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/2] liquidio: VF driver will notify NIC
 firmware of MTU change
Date: Tue, 22 Aug 2017 11:08:30 -0700 (PDT)
Message-ID: <20170822.110830.1871201094263633068.davem@davemloft.net>
References: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdHVSIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:08:31 -0400
In-Reply-To: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 21 Aug 2017 12:35:27 -0700

> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> 
> Make VF driver notify NIC firmware of MTU change.  Firmware needs this
> information for MTU propagation and enforcement.
> 
> The first patch in this series moves a macro definition to a proper place
> to prevent a build error in the second patch which has the code that sends
> the notification.
> 
> Change Log:
>   V1 -> V2
>     * Add "From:" line to patch #1 and #2 to give credit to the author.
>     * In patch #2, order local variable declarations from longest to
>       shortest line.

Series applied.
