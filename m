From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 7 Dec 2016 11:39:55 +0800
Message-ID: <7c1062f8-d040-bdfd-7578-660506e48baa@redhat.com>
References: <1480584880-48651-1-git-send-email-andreyknvl@google.com>
 <20161201.144357.33718747165573960.davem@davemloft.net>
 <f7d8e34b-0ceb-8fef-52f3-df4cc7d2c6c5@redhat.com>
 <20161206.222523.2232014563426365529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: andreyknvl@google.com, herbert@gondor.apana.org.au,
        edumazet@google.com, pmk@google.com, pabeni@redhat.com,
        mst@redhat.com, soheil@google.com, elfring@users.sourceforge.net,
        rppt@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dvyukov@google.com, kcc@google.com,
        syzkaller@googlegroups.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161206.222523.2232014563426365529.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年12月07日 11:25, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 7 Dec 2016 11:21:11 +0800
>
>> David, looks like this commit is not in net-next.git.
>>
>> Please help to check.
> Take a look, it should be there now.

Yes, thanks.
