From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Thu, 8 Sep 2016 16:31:22 +0200
Message-ID: <24063985-7837-ca69-6da0-6522dd1e9dbb@6wind.com>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: =?UTF-8?Q?Ilpo_J=c3=a4rvinen?= <ilpo.jarvinen@helsinki.fi>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37532 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941564AbcIHOb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 10:31:26 -0400
Received: by mail-wm0-f50.google.com with SMTP id w12so92918595wmf.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 07:31:25 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/09/2016 à 13:02, Ilpo Järvinen a écrit :
[snip]
> Acked-By: Ilpo Järvinen <ilpo.jarvinen@helsinki>
Also nitpicking: the end of the email address is missing ;-)
