From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] Fix DMA channel misreporting for the Renesas Ethernet
 drivers
Date: Mon, 18 Jul 2016 17:13:02 +0300
Message-ID: <3244a329-1b48-4e09-7fe5-96d80b8a3d54@cogentembedded.com>
References: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
 <20160717.232451.295029329698830463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20160717.232451.295029329698830463.davem@davemloft.net>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/18/2016 09:24 AM, David Miller wrote:

>>    Here's a set of 2 patches against DaveM's 'net.git' repo fixing
>> up the DMA channel reporting by 'ifconfig'...
>
> Is some fixing some ifconfig output that is effectively meaningless
> appropriate for 'net'?

    I just don't know any more users of SIOCGIFMAP ioctl... ip?
    It seems to  also be used in net/core/rtnetlink.c...

> Sounds like 'net-next' material to me.

    Up to you, of course.

MBR, Sergei
