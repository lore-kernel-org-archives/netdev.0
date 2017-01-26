From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net: Fix ndo_setup_tc comment
Date: Thu, 26 Jan 2017 14:59:34 -0800
Message-ID: <588A7F56.2080206@gmail.com>
References: <20170126224417.10327-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, john.r.fastabend@intel.com, jiri@mellanox.com,
        jhs@mojatatu.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34765 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdAZXBR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:01:17 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so17268373pfb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 14:59:49 -0800 (PST)
In-Reply-To: <20170126224417.10327-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-26 02:44 PM, Florian Fainelli wrote:
> Commit 16e5cc647173 ("net: rework setup_tc ndo op to consume
> general tc operand") changed the ndo_setup_tc() signature, but did not
> update the comments in netdevice.h, so do that now.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---

Thanks.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
