From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 8/9] ipv6: drop unused variables in
 seg6_genl_dumphac
Date: Sun, 21 May 2017 13:43:57 -0400 (EDT)
Message-ID: <20170521.134357.2047892704931721755.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-9-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45228 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756855AbdEURn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:59 -0400
In-Reply-To: <20170519165556.483-9-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 May 2017 09:55:55 -0700

> THe seg6_pernet_data variable was set but never used.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
