From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Thu, 1 Dec 2016 21:28:40 +0300
Message-ID: <88d53871-c45f-c45c-bd72-f6b363f7ea6b@cogentembedded.com>
References: <20161201140642.28583-1-chris.brandt@renesas.com>
 <228704e3-fe33-1c1f-61a1-7db451af5faf@cogentembedded.com>
 <7d50b5e0-ae7c-a39d-625a-c9cfc11e398f@cogentembedded.com>
 <SG2PR06MB1165DFB4E735FC10696F08CA8A8F0@SG2PR06MB1165.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>
To: Chris Brandt <Chris.Brandt@renesas.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <SG2PR06MB1165DFB4E735FC10696F08CA8A8F0@SG2PR06MB1165.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/01/2016 09:24 PM, Chris Brandt wrote:

>>     One thing you've missed so far is mentioning R7S72100 (RZ/A1) in the
>> subject. This driver supports many SoCs, you're only fixing one of them...
>
> For the last sh_eth.c patch I submitted, I had:
>
> "net: ethernet: renesas: sh_eth: add POST registers for rz"
>
>
> Should I resend the patch as:
>
> "[PATCH v3] sh_eth: remove unchecked interrupts for RZ/A1"
>
>
> ??

    Yes, that will do.

> Chris

MBR, Sergei
