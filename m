From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v9 5/5] virtio_net: check return value of
 skb_to_sgvec always
Date: Wed, 24 May 2017 19:41:15 +0300
Message-ID: <decd478f-0d5d-af6a-5b59-b710658ea16b@cogentembedded.com>
References: <20170523160550.5203-1-Jason@zx2c4.com>
 <20170523160550.5203-6-Jason@zx2c4.com>
 <911d6dda-85de-ba8d-0c84-6a37e91523de@cogentembedded.com>
 <CAHmME9qg6_3PfKKarepCmp3yF6MTTQa0xwZPLz=EYKheTUYNdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36032 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761530AbdEXQlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:41:19 -0400
Received: by mail-lf0-f50.google.com with SMTP id h4so70768276lfj.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 09:41:18 -0700 (PDT)
In-Reply-To: <CAHmME9qg6_3PfKKarepCmp3yF6MTTQa0xwZPLz=EYKheTUYNdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 02:34 PM, Jason A. Donenfeld wrote:

> I'm shocked this somehow made it into the commit. I wonder how that happened?

    Sorry for not noticing this when it first appeared.

> Anyway, fixed in my git repo, and will be part of the next series.
> (Unless DaveM wants to fix it up trivially when/if he merges this v9,
> which would be faster.)
>
> Barring that, does this look good to you? Could I have your signed-off-by?

    I've only looked on the last 2 patches. You can add my:

Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

if you want. :-)

> Regards,
> Jason

MBR, Sergei
