From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/9] xfrm: make xfrm_dev_register static
Date: Sun, 21 May 2017 13:43:46 -0400 (EDT)
Message-ID: <20170521.134346.439576319049482359.davem@davemloft.net>
References: <20170519165556.483-1-sthemmin@microsoft.com>
        <20170519165556.483-7-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEURns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:43:48 -0400
In-Reply-To: <20170519165556.483-7-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 May 2017 09:55:53 -0700

> This function is only used in this file and should not be global.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Steffen said he already took this.
