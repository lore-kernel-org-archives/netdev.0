From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net-next v9 5/5] virtio_net: check return value of
 skb_to_sgvec always
Date: Wed, 24 May 2017 13:34:34 +0200
Message-ID: <CAHmME9qg6_3PfKKarepCmp3yF6MTTQa0xwZPLz=EYKheTUYNdQ@mail.gmail.com>
References: <20170523160550.5203-1-Jason@zx2c4.com> <20170523160550.5203-6-Jason@zx2c4.com>
 <911d6dda-85de-ba8d-0c84-6a37e91523de@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <911d6dda-85de-ba8d-0c84-6a37e91523de@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm shocked this somehow made it into the commit. I wonder how that happened?

Anyway, fixed in my git repo, and will be part of the next series.
(Unless DaveM wants to fix it up trivially when/if he merges this v9,
which would be faster.)

Barring that, does this look good to you? Could I have your signed-off-by?

Regards,
Jason
