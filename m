From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/sched: Use TC skip flags to reflect
 HW offload status
Date: Sun, 12 Feb 2017 11:50:12 -0500 (EST)
Message-ID: <20170212.115012.462374721298882143.davem@davemloft.net>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
        <20170210.143636.253114480501653886.davem@davemloft.net>
        <CAJ3xEMh=zOZX0yQEoi0T_zC+je2_ux=mSW0qG_sSr+2eyA_81A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, daniel@iogearbox.net,
        jakub.kicinski@netronome.com, john.r.fastabend@intel.com,
        amir@vadai.me, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, roid@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751276AbdBLQuQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 11:50:16 -0500
In-Reply-To: <CAJ3xEMh=zOZX0yQEoi0T_zC+je2_ux=mSW0qG_sSr+2eyA_81A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Sun, 12 Feb 2017 11:54:25 +0200

> Re the old kernel argument, these patches are small and pointish,
> would it make sense to you to consider them as fixes and push them
> back to the relevant stable kernels?

Sorry, it doesn't work that way.
