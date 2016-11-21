From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] geneve: Use LWT more effectively.
Date: Mon, 21 Nov 2016 11:28:53 -0500 (EST)
Message-ID: <20161121.112853.596026767987561055.davem@davemloft.net>
References: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755005AbcKUQhF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:37:05 -0500
In-Reply-To: <1479521411-53012-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri, 18 Nov 2016 18:10:07 -0800

> Following patch series make use of geneve LWT code path for
> geneve netdev type of device.
> This allows us to simplify geneve module.
> 
> v1-v2:
> Fix warning reported by kbuild test robot.

This doesn't apply cleanly to net-next, please respin.

Thanks.
