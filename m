From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v9 5/5] virtio_net: check return value of
 skb_to_sgvec always
Date: Wed, 24 May 2017 23:46:01 +0300
Message-ID: <f38acbfb-4401-acf6-6a62-9d7af426488d@cogentembedded.com>
References: <20170523160550.5203-1-Jason@zx2c4.com>
 <20170523160550.5203-6-Jason@zx2c4.com>
 <911d6dda-85de-ba8d-0c84-6a37e91523de@cogentembedded.com>
 <CAHmME9qg6_3PfKKarepCmp3yF6MTTQa0xwZPLz=EYKheTUYNdQ@mail.gmail.com>
 <decd478f-0d5d-af6a-5b59-b710658ea16b@cogentembedded.com>
 <CAHmME9obros-WAMC69VWrg=Djb_ZwKz9WyBVvKkAMHmC3N87SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9obros-WAMC69VWrg=Djb_ZwKz9WyBVvKkAMHmC3N87SA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/24/2017 11:39 PM, Jason A. Donenfeld wrote:

>>    I've only looked on the last 2 patches. You can add my:
>>
>> Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> if you want. :-)
>
> Will do. For the series, or just for 5/5?

    5/5 only. :-)

MBR, Sergei
