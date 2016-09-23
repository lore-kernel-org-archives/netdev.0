From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next] Documentation: devicetree: revise ethernet device-tree binding about TRGMII
Date: Fri, 23 Sep 2016 10:52:40 +0800
Message-ID: <1474599160-7958-1-git-send-email-sean.wang@mediatek.com>
References: <0582f22e-6e6f-1564-fcdd-1bcfc3562cf3@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <john@phrozen.org>, <davem@davemloft.net>, <nbd@openwrt.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>
To: <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0582f22e-6e6f-1564-fcdd-1bcfc3562cf3@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Date: Thu, 22 Sep 2016 19:48:47 +0300, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>On 09/22/2016 07:16 PM, sean.wang@mediatek.com wrote:
>
>> From: Sean Wang <sean.wang@mediatek.com>
>>
>> fix typo in mediatek-net.txt and add phy-mode "trgmii" to ethernet.txt
>
>    These changes are unrelated to each other, so there should be 2 separate 
>patches. And have the patches I reviewed been merged already, why are you 
>sending an incremental patch?
>

okay, I will make them into distinct patchs.

I saw they had been applied so I created an incremental
patch based on codebase after applied.

>> Cc: devicetree@vger.kernel.org
>> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
>[...]
>
>MBR, Sergei
>
>
