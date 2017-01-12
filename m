From: David Miller <davem@davemloft.net>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 15:27:57 -0500 (EST)
Message-ID: <20170112.152757.935482756436143738.davem@davemloft.net>
References: <CAHmME9oYDdQGsQ8jQGJMeJ-0A6O+Och+Y+5Q_=Q=M9qgrxDq2Q@mail.gmail.com>
        <20170112.141127.426662758858102403.davem@davemloft.net>
        <CAHmME9oYtxL=sBpOquOjcqtQnYY=AFHC+OqMdeQD6X8HNoY4zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, stephen@networkplumber.org, netdev@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750772AbdALU17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:27:59 -0500
In-Reply-To: <CAHmME9oYtxL=sBpOquOjcqtQnYY=AFHC+OqMdeQD6X8HNoY4zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 12 Jan 2017 21:07:43 +0100

> David - you concur with Stephen that ioctl is really not okay and I
> should absolutely do netlink?

Yes.
