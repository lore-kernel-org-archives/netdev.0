From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: ipset losing entries on its own
Date: Thu, 7 Sep 2017 14:11:01 +0530
Message-ID: <CAA5aLPgM9=VU4Cysy-LtN-uXPqvG00X2v8MP9EM5RtPVB6tGvw@mail.gmail.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
 <c7abf292ac5e6202993a10a66537141e@nuclearcat.com> <CAA5aLPgUcrUpqJJ8stu1543LBy0qekgQDuJyokqLPP0TirySgg@mail.gmail.com>
 <CAA5aLPiENU+k0=tH1jPvSdmdEcMDFfgk0FQcHxWvz8tYCaNZzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:38335 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752778AbdIGIlC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 04:41:02 -0400
In-Reply-To: <CAA5aLPiENU+k0=tH1jPvSdmdEcMDFfgk0FQcHxWvz8tYCaNZzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another observation :
At times rehashing happens (v6.32) and hashsize increases to 2048 from
1024. But this is at times and not always. Needless to mention, it is
for exactly same IPs added to the ipset in exactly same order.
