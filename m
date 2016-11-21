From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] geneve: Use LWT more effectively.
Date: Mon, 21 Nov 2016 14:06:15 -0500 (EST)
Message-ID: <20161121.140615.1109479470539950510.davem@davemloft.net>
References: <1479754981-17600-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754190AbcKUTGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:06:17 -0500
In-Reply-To: <1479754981-17600-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Mon, 21 Nov 2016 11:02:57 -0800

> Following patch series make use of geneve LWT code path for
> geneve netdev type of device.
> This allows us to simplify geneve module without changing any
> functionality.
> 
> v2-v3:
> Rebase against latest net-next.
> 
> v1-v2:
> Fix warning reported by kbuild test robot.

Series applied, thanks Pravin.
