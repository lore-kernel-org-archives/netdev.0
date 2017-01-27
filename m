From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] ravb: Support 1Gbps on R-Car H3 ES1.1+ and
 R-Car M3-W
Date: Fri, 27 Jan 2017 15:52:10 +0300
Message-ID: <1a03b93c-3793-a9c5-14df-010c24b4f3a9@cogentembedded.com>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <1485515090-7570-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32882 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754774AbdA0MxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 07:53:10 -0500
Received: by mail-lf0-f52.google.com with SMTP id x1so74724049lff.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 04:52:13 -0800 (PST)
In-Reply-To: <1485515090-7570-3-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 02:04 PM, Simon Horman wrote:

> From: Geert Uytterhoeven <geert+renesas@glider.be>
>
> The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
> ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
> revisions of R-Car H3, and on R-Car M3-W.
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
