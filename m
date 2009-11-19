From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH] ieee802154: dont leak skbs in ieee802154_fake_xmit()
Date: Thu, 19 Nov 2009 18:57:48 +0300
Message-ID: <bc64b4640911190757w7eea481sd346085e3ceb1276@mail.gmail.com>
References: <4B052BCA.4020901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:33662 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbZKSP5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 10:57:42 -0500
Received: by ywh40 with SMTP id 40so1388586ywh.33
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 07:57:48 -0800 (PST)
In-Reply-To: <4B052BCA.4020901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2009 at 2:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> ieee802154_fake_xmit() should free skbs since it returns NETDEV_TX_OK

Acked-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

David, please apply.

-- 
With best wishes
Dmitry
