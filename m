From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 iproute] ip: Add support for netdev events to monitor
Date: Sat, 08 Apr 2017 19:33:11 -0700 (PDT)
Message-ID: <20170408.193311.1975315968848220462.davem@davemloft.net>
References: <1491312333-18904-1-git-send-email-vyasevic@redhat.com>
        <0a7efd86-3345-223a-7a39-8c8cd1a42f14@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34962 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdDICdP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 22:33:15 -0400
In-Reply-To: <0a7efd86-3345-223a-7a39-8c8cd1a42f14@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 8 Apr 2017 18:24:06 -0400

> per comments on the email thread about reducing notifications, the
> kernel patch for this should be reverted (and hence this iproute2 patch
> is not needed) in favor of using a bitmask. Right now there are too many
> redundant notifications to userspace.

I must have missed something in all the discussion, which patch needs
to be reverted from my tree exactly?
