From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Tue, 02 Dec 2014 23:41:22 -0800
Message-ID: <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141103.122538.387451917276174830.davem@davemloft.net>
	 <547EBC66.4040301@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	willemb@google.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34587 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaLCHlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 02:41:24 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so12641092iec.8
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 23:41:23 -0800 (PST)
In-Reply-To: <547EBC66.4040301@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-03 at 15:31 +0800, Yang Yingliang wrote:

> This patch can resolve my performance problem.
> Will/Can this patch queue for stable ?

Hmm.. please give us more details, I am surprised it can have
a big impact.
