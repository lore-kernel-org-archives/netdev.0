From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Mon, 27 Mar 2017 15:52:42 -0700 (PDT)
Message-ID: <20170327.155242.862536720570878301.davem@davemloft.net>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com, ebiederm@xmission.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbdC0Wwt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 18:52:49 -0400
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat, 25 Mar 2017 10:03:24 -0700

> Bump the maximum number of labels for MPLS routes from 2 to 12.

This doesn't apply cleanly to net-next, please respin.

Perhaps it conflicts with your recent cleanups.
