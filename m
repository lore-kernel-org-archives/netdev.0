From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net]ipv6: Provide ipv6 version of "disable_policy"
 sysctl
Date: Mon, 06 Mar 2017 17:11:09 -0800 (PST)
Message-ID: <20170306.171109.1614519262967833329.davem@davemloft.net>
References: <1487867238-27179-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dforster@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753253AbdCGBLK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 20:11:10 -0500
In-Reply-To: <1487867238-27179-1-git-send-email-dforster@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Forster <dforster@brocade.com>
Date: Thu, 23 Feb 2017 16:27:18 +0000

> This provides equivalent functionality to the existing ipv4
> "disable_policy" systcl. ie. Allows IPsec processing to be skipped
> on terminating packets on a per-interface basis.
> 
> Signed-off-by: David Forster <dforster@brocade.com>

Applied to net-next, thanks David.
