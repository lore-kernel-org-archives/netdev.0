From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] net: ethernet: mediatek: bug fix to disable
 HW LRO
Date: Mon, 26 Sep 2016 14:21:15 +0300
Message-ID: <7124ebf3-8001-ed55-d727-3a524e0088ee@cogentembedded.com>
References: <1474871630-4134-1-git-send-email-nelson.chang@mediatek.com>
 <1474871630-4134-3-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, nelsonch.tw@gmail.com
To: Nelson Chang <nelson.chang@mediatek.com>, john@phrozen.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33276 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbcIZLVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 07:21:19 -0400
Received: by mail-lf0-f51.google.com with SMTP id b71so111348269lfg.0
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 04:21:18 -0700 (PDT)
In-Reply-To: <1474871630-4134-3-git-send-email-nelson.chang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/26/2016 9:33 AM, Nelson Chang wrote:

> (1) Modify the register settings for LRO relinquishments
> (2) Jump out from the waiting loop while LRO relinquishments are done

    Why this is done in a single patch?

> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
[...]

MBR, Sergei
