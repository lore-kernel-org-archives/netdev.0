From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Network driver "test suite"
Date: Wed, 12 Apr 2017 17:47:53 +1000
Message-ID: <1491983273.7236.50.camel@kernel.crashing.org>
References: <1491956177.7236.34.camel@kernel.crashing.org>
         <3c62188f-1378-a912-3045-97644fa386d5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52585 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751308AbdDLHsM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 03:48:12 -0400
In-Reply-To: <3c62188f-1378-a912-3045-97644fa386d5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 17:36 -0700, Florian Fainelli wrote:
> 
> You could start with using LNST:
> 
> https://github.com/jpirko/lnst
> 
> and there is also Ostinato which is a great way to get access to
> something IXIA-like, but all configurable in software through python
> bindings. Andrew's dsa-tests make use of it, but they would not be
> directly portable here [1].
> 
> [1]: https://github.com/lunn/dsa-tests

Thanks. I'll play with these when I have a bit of spare time !

Cheers,
Ben.
