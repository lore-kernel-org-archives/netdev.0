From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: don't call strlen() on the user buffer in
 packet_bind_spkt()
Date: Tue, 28 Feb 2017 05:54:25 -0800
Message-ID: <1488290065.9415.257.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170228131759.110380-1-glider@google.com>
         <1488288789.9415.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488289373.9415.251.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAG_fn=V2J_dp+bASVdkLTnx1jQDHSda4pzQyVGBRHH-NBQHEgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitriy Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35887 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdB1ODf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 09:03:35 -0500
In-Reply-To: <CAG_fn=V2J_dp+bASVdkLTnx1jQDHSda4pzQyVGBRHH-NBQHEgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 14:47 +0100, Alexander Potapenko wrote:

> SGTM. Shall I send the updated patch? (Sorry for asking, the patch
> culture is hard)

It is always nice to wait for feedback(s), before sending a v2, and a
v3, and a v4.

Sending 4 patches in one hour is considered not friendly ;)

So if I were you, I would wait a bit for additional comments before
sending a new version.

Thanks.
