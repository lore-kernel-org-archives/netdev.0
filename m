From: Alexander Sverdlin <alexander.sverdlin@gmail.com>
Subject: Re: [PATCH v2 net-next 06/12] ep93xx_eth: add GRO support
Date: Mon, 15 May 2017 23:02:50 +0200
Message-ID: <1494882170.2185.2.camel@Nokia-N900>
References: <20170204232502.22361-1-edumazet@google.com>
         <20170204232502.22361-7-edumazet@google.com>
         <20170515103132.GA24992@wantstofly.org>  <591A12E8.1050603@gmail.com>
Reply-To: Alexander Sverdlin <alexander.sverdlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hartley Sweeten <hsweeten@visionengravers.com>
To: Ryan Mallon <rmallon@gmail.com>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32951 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756678AbdEOVC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 17:02:59 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so31719213wmh.0
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 14:02:58 -0700 (PDT)
In-Reply-To: <591A12E8.1050603@gmail.com>
Content-ID: <1494882168.2185.1.camel@Nokia-N900>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Mon May 15 22:43:20 2017 Ryan Mallon <rmallon@gmail.com> wrote:
> > I don't know if we really care about this hardware anymore (I don't),
> > but the ep93xx platform is still listed as being maintained in the
> > MAINTAINERS file -- adding Ryan and Hartley.
> 
> I no longer have any ep93xx hardware to test with, and I never looked at
> the Ethernet, so don't know the details. I think there are still a
> handful of users. Adding Alexander who sent an ADC support series this
> week, who might be able to test this?

Yes, I very much care about ep93xx code being functional :)
I'll test the patches tomorrow.

Alexander.
