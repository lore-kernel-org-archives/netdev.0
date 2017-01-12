From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC net] ravb: Remove Rx overflow log messages
Date: Thu, 12 Jan 2017 14:52:02 +0300
Message-ID: <026e0290-f051-f60c-33bb-0c12012b0e4e@cogentembedded.com>
References: <1484210470-3095-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35950 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750910AbdALLwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 06:52:07 -0500
Received: by mail-lf0-f43.google.com with SMTP id z134so7701151lff.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 03:52:06 -0800 (PST)
In-Reply-To: <1484210470-3095-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 11:41 AM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> Remove Rx overflow log messages as in an environment where logging results
> in network traffic logging may cause further overflows.
>
> Fixes: c156633f1353 ("Renesas Ethernet AVB driver proper")
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked changelog]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
