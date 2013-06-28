From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] net: Check the argument for listen(2)
Date: Sat, 29 Jun 2013 00:47:34 +0800
Message-ID: <CABa6K_EkNEkzHunU8mBgagtQWb-rvTe_uf0x-cSXYVP-h+wCew@mail.gmail.com>
References: <1372436577-61749-1-git-send-email-xiaosuo@gmail.com> <1372437203.3301.288.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:33998 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab3F1Qrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:47:55 -0400
Received: by mail-ie0-f181.google.com with SMTP id x12so4483294ief.40
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:47:54 -0700 (PDT)
In-Reply-To: <1372437203.3301.288.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 12:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Well, there is still this possible regression for old applications.
>
> Just use u32 fields instead of u16 ?
>

I'll look at this. Thanks.

--
Regards,
Changli Gao(xiaosuo@gmail.com)
