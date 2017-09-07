From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: ipset losing entries on its own
Date: Thu, 7 Sep 2017 10:18:34 +0530
Message-ID: <CAA5aLPgUcrUpqJJ8stu1543LBy0qekgQDuJyokqLPP0TirySgg@mail.gmail.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
 <c7abf292ac5e6202993a10a66537141e@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:37446 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIGEsg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:48:36 -0400
In-Reply-To: <c7abf292ac5e6202993a10a66537141e@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I understand that without reproducible scenarios, its hard to debug ...
But the point is, this issue is fully random and of very low frequency.

For the setup, it is CentOS 7.3 upgraded to kernel 4.4.

Whenever a system comes up on the network, he provides his credentials
and after successful authentication, his IP is added in an IPSET which
is having access to certain resources.
