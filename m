From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next v3 af-packet 2/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Mon, 18 Jul 2011 10:55:59 -0400
Message-ID: <CAAsGZS56pDHR_Gc0j9sKPHu9R5VKcyvpajw_v9ohhn63ti4hYQ@mail.gmail.com>
References: <1310959610-1688-1-git-send-email-loke.chetan@gmail.com>
	<1310959610-1688-3-git-send-email-loke.chetan@gmail.com>
	<1310960790.2286.39.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64983 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924Ab1GROz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 10:55:59 -0400
Received: by pvg12 with SMTP id 12so3048675pvg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 07:55:59 -0700 (PDT)
In-Reply-To: <1310960790.2286.39.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 17, 2011 at 11:46 PM, Joe Perches <joe@perches.com> wrote:
>
> Maybe just use the kernel.h macro ALIGN()?

Ok. Actually, I was going to use ALIGN but then to have similar
look&feel as that of V1[2], I defined the V3_ALIGNMENT macro.

Chetan Loke
