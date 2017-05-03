From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Fix warning of freeing alive inet6 address
Date: Wed, 03 May 2017 10:22:32 -0400 (EDT)
Message-ID: <20170503.102232.973033131580337728.davem@davemloft.net>
References: <1493749857-18032-1-git-send-email-mmanning@brocade.com>
        <1fb7b6de-ddb8-0207-0567-91d1ed0aad83@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdECOWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 10:22:34 -0400
In-Reply-To: <1fb7b6de-ddb8-0207-0567-91d1ed0aad83@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Wed, 3 May 2017 15:16:20 +0100

> On reflection, please put this on hold subject to testing with
> syzkaller. I have not had a repro of the issue and so the fix even
> though harmless may not be effective.

Ok.
