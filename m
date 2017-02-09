From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 0/2] net: ethernet: ti: cpsw: fix susp/resume
Date: Fri, 10 Feb 2017 00:54:24 +0200
Message-ID: <20170209225423.GA15853@khorivan>
References: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <20170209.172126.155005439329995220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org, AStarikovskiy@topcon.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:36274 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbdBIXTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 18:19:54 -0500
Received: by mail-lf0-f54.google.com with SMTP id z134so11546088lff.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 15:19:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170209.172126.155005439329995220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 09, 2017 at 05:21:26PM -0500, David Miller wrote:
> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Date: Thu,  9 Feb 2017 02:07:34 +0200
> 
> > These two patches fix suspend/resume chain.
> 
> Patch 2 doesn't apply cleanly to the 'net' tree, please
> respin this series.

Strange, I've just checked it on net-next/master, it was applied w/o any
warnings.
