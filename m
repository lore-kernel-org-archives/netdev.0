From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: ethernet: ti: cpsw: fix susp/resume
Date: Thu, 09 Feb 2017 20:45:07 -0500 (EST)
Message-ID: <20170209.204507.954952367013216032.davem@davemloft.net>
References: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
        <20170209.172126.155005439329995220.davem@davemloft.net>
        <20170209225423.GA15853@khorivan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org, AStarikovskiy@topcon.com
To: ivan.khoronzhuk@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdBJBpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 20:45:10 -0500
In-Reply-To: <20170209225423.GA15853@khorivan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Fri, 10 Feb 2017 00:54:24 +0200

> On Thu, Feb 09, 2017 at 05:21:26PM -0500, David Miller wrote:
>> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> Date: Thu,  9 Feb 2017 02:07:34 +0200
>> 
>> > These two patches fix suspend/resume chain.
>> 
>> Patch 2 doesn't apply cleanly to the 'net' tree, please
>> respin this series.
> 
> Strange, I've just checked it on net-next/master, it was applied w/o any
> warnings.

It makes no sense to test "net-next" when I am telling you that it is
the "net" tree it doesn't apply to.

This is a bug fix, so it should be targetting the "net" tree.
